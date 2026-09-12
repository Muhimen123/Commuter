-- =====================================================================
-- COMMUTER APP — ROUTE MATCHING (bus dedup + stop proximity matching)
--
-- Additive on top of schema.sql and journey_rls_and_rpcs.sql. Apply
-- journey_rls_and_rpcs.sql FIRST, then this file — the add_journey_stop
-- function below is a CREATE OR REPLACE that supersedes the one defined
-- there, adding a route_stops sync step. Every statement in this file
-- is idempotent (CREATE OR REPLACE / IF NOT EXISTS), so it's safe to
-- re-run.
--
-- Problem this solves:
--   1. Starting a journey with a brand-new bus name should create a
--      real `routes` row for it instead of leaving route_id null.
--   2. Starting a journey with a bus name that matches an existing
--      route should reuse that route, not create a duplicate.
--   3. Stops added mid-journey should also land in that route's
--      route_stops — but a stop within ~300m of one the route already
--      has is the same physical stop, so it should be reused rather
--      than duplicated. Matching is scoped to stops on the SAME route
--      only (not a global stop registry — routes own their stops
--      directly in this schema, no shared stops table).
--
-- No PostGIS is installed in this project (only uuid-ossp — see
-- schema.sql), so proximity is computed with a plain haversine formula
-- in plpgsql rather than ST_DWithin/geography columns.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Uniqueness on route_name (case/whitespace-insensitive) so concurrent
-- "brand-new bus name" journey-starts can't create two routes for the
-- same name. This is what makes find_or_create_route_by_name race-safe
-- below: Postgres takes a row lock on the conflicting unique-index
-- entry, so a second concurrent INSERT blocks until the first commits.
-- ---------------------------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS idx_routes_route_name_unique
  ON routes (lower(btrim(route_name)));

-- ---------------------------------------------------------------------
-- haversine_meters(lat1, lon1, lat2, lon2)
-- Great-circle distance in meters between two lat/lng points. Plain
-- formula, no PostGIS required. IMMUTABLE since it's a pure function
-- of its inputs.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION haversine_meters(
  lat1 NUMERIC, lon1 NUMERIC, lat2 NUMERIC, lon2 NUMERIC
) RETURNS DOUBLE PRECISION
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  c_earth_radius_meters CONSTANT DOUBLE PRECISION := 6371000;
  v_dlat DOUBLE PRECISION;
  v_dlon DOUBLE PRECISION;
  v_a DOUBLE PRECISION;
BEGIN
  v_dlat := radians(lat2 - lat1);
  v_dlon := radians(lon2 - lon1);
  v_a := sin(v_dlat / 2) ^ 2
       + cos(radians(lat1)) * cos(radians(lat2)) * sin(v_dlon / 2) ^ 2;
  RETURN c_earth_radius_meters * 2 * asin(sqrt(v_a));
END;
$$;

GRANT EXECUTE ON FUNCTION haversine_meters(NUMERIC, NUMERIC, NUMERIC, NUMERIC)
  TO anon, authenticated;

-- ---------------------------------------------------------------------
-- find_or_create_route_by_name(p_bus_name)
-- Returns the existing route matching p_bus_name (case/whitespace-
-- insensitive), or creates one if none exists. Race-safe: the INSERT
-- either wins outright, or backs off on the unique-index conflict and
-- reads the row the winning concurrent caller committed.
--
-- KNOWN SIMPLIFICATION: a free-typed bus name has no real route
-- number, so route_number is set equal to route_name here. This is a
-- placeholder value, not a real route number.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION find_or_create_route_by_name(
  p_bus_name VARCHAR
) RETURNS routes
LANGUAGE plpgsql
AS $$
DECLARE
  v_route routes;
BEGIN
  INSERT INTO routes (route_number, route_name)
  VALUES (p_bus_name, p_bus_name)
  ON CONFLICT ((lower(btrim(route_name)))) DO NOTHING
  RETURNING * INTO v_route;

  IF v_route.id IS NOT NULL THEN
    RETURN v_route;
  END IF;

  SELECT * INTO v_route
    FROM routes
   WHERE lower(btrim(route_name)) = lower(btrim(p_bus_name))
   LIMIT 1;

  RETURN v_route;
END;
$$;

GRANT EXECUTE ON FUNCTION find_or_create_route_by_name(VARCHAR)
  TO anon, authenticated;

-- ---------------------------------------------------------------------
-- add_or_reuse_route_stop(p_route_id, p_stop_name, p_latitude, p_longitude)
-- Reuses the nearest existing route_stop on this route if it's within
-- 300m (a single plain constant — no weighting, no config table);
-- otherwise inserts a new route_stop with the next sequence_order.
--
-- An advisory transaction lock on the route id serializes concurrent
-- adds to the same route, so two near-simultaneous "new" stops can't
-- both slip past the proximity check and create duplicates.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION add_or_reuse_route_stop(
  p_route_id  UUID,
  p_stop_name VARCHAR,
  p_latitude  NUMERIC,
  p_longitude NUMERIC
) RETURNS route_stops
LANGUAGE plpgsql
AS $$
DECLARE
  c_stop_match_radius_meters CONSTANT NUMERIC := 300;
  v_match      route_stops;
  v_next_order INTEGER;
BEGIN
  PERFORM pg_advisory_xact_lock(hashtext(p_route_id::text));

  SELECT rs.*
    INTO v_match
    FROM route_stops rs
   WHERE rs.route_id = p_route_id
     AND haversine_meters(rs.latitude, rs.longitude, p_latitude, p_longitude)
           <= c_stop_match_radius_meters
   ORDER BY haversine_meters(rs.latitude, rs.longitude, p_latitude, p_longitude) ASC
   LIMIT 1;

  IF v_match.id IS NOT NULL THEN
    RETURN v_match;
  END IF;

  SELECT COALESCE(MAX(sequence_order), 0) + 1
    INTO v_next_order
    FROM route_stops
   WHERE route_id = p_route_id;

  INSERT INTO route_stops (route_id, stop_name, latitude, longitude, sequence_order)
  VALUES (p_route_id, p_stop_name, p_latitude, p_longitude, v_next_order)
  RETURNING * INTO v_match;

  RETURN v_match;
END;
$$;

GRANT EXECUTE ON FUNCTION add_or_reuse_route_stop(UUID, VARCHAR, NUMERIC, NUMERIC)
  TO anon, authenticated;

-- ---------------------------------------------------------------------
-- add_journey_stop(p_journey_id, p_stop_name, p_latitude, p_longitude)
-- SUPERSEDES the version in journey_rls_and_rpcs.sql. Same signature,
-- same return shape (a journey_stops row) — no client-visible change.
-- Still always appends a journey_stops row with the next
-- sequence_order. Additionally, when the journey is tied to a route,
-- syncs route_stops in the SAME transaction via add_or_reuse_route_stop
-- — if that fails, the whole call rolls back, so the two tables never
-- drift out of sync.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION add_journey_stop(
  p_journey_id UUID,
  p_stop_name   VARCHAR,
  p_latitude    NUMERIC(9,6),
  p_longitude   NUMERIC(9,6)
) RETURNS journey_stops
LANGUAGE plpgsql
AS $$
DECLARE
  v_next_order INTEGER;
  v_inserted   journey_stops;
  v_route_id   UUID;
BEGIN
  SELECT COALESCE(MAX(sequence_order), 0) + 1
    INTO v_next_order
    FROM journey_stops
   WHERE journey_id = p_journey_id;

  INSERT INTO journey_stops (journey_id, stop_name, latitude, longitude, sequence_order)
  VALUES (p_journey_id, p_stop_name, p_latitude, p_longitude, v_next_order)
  RETURNING * INTO v_inserted;

  SELECT route_id INTO v_route_id FROM journeys WHERE id = p_journey_id;

  IF v_route_id IS NOT NULL THEN
    PERFORM add_or_reuse_route_stop(v_route_id, p_stop_name, p_latitude, p_longitude);
  END IF;

  RETURN v_inserted;
END;
$$;

GRANT EXECUTE ON FUNCTION add_journey_stop(UUID, VARCHAR, NUMERIC, NUMERIC)
  TO anon, authenticated;
