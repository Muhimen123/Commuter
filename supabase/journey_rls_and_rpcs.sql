-- =====================================================================
-- COMMUTER APP — JOURNEY BACKEND (RLS + grants + RPC functions)
--
-- Additive to schema.sql. Covers the journey tables:
--   journeys, journey_stops, journey_location_pings, post_ride_surveys
--
-- AUTH STATUS: client auth is mocked (no real Supabase Auth session yet).
-- RLS here is intentionally PERMISSIVE so the dev user id
-- ('00000000-0000-0000-0000-000000000001', see seed.sql) can read/write
-- via the anon key. When real Supabase Auth lands, replace the *_dev_all
-- policies with auth-uid-scoped ones (see TODO blocks below) and revisit
-- whether these RPCs should become SECURITY DEFINER with ownership checks.
--
-- NOTE: post_ride_surveys setup lives in the MIGRATION section at the
-- very bottom of this file. If you already ran an earlier version of
-- this file (before post_ride_surveys existed), run ONLY that section.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Enable Row Level Security
-- ---------------------------------------------------------------------
ALTER TABLE journeys                ENABLE ROW LEVEL SECURITY;
ALTER TABLE journey_stops           ENABLE ROW LEVEL SECURITY;
ALTER TABLE journey_location_pings  ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------
-- Table-level grants to anon + authenticated roles
-- (RLS is row-level; the role still needs table privileges.)
-- ---------------------------------------------------------------------
GRANT ALL ON journeys              TO anon, authenticated;
GRANT ALL ON journey_stops         TO anon, authenticated;
GRANT ALL ON journey_location_pings TO anon, authenticated;

-- BIGSERIAL sequence backing journey_location_pings.id — INSERT needs USAGE.
GRANT USAGE, SELECT ON journey_location_pings_id_seq TO anon, authenticated;

-- ---------------------------------------------------------------------
-- PERMISSIVE DEV POLICIES (allow everything)
-- TODO(real-auth): drop these and replace with, e.g.:
--
--   CREATE POLICY journeys_select_own ON journeys
--     FOR SELECT USING (auth.uid() = user_id);
--   CREATE POLICY journeys_insert_own ON journeys
--     FOR INSERT WITH CHECK (auth.uid() = user_id);
--   CREATE POLICY journeys_update_own ON journeys
--     FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
--   CREATE POLICY journeys_delete_own ON journeys
--     FOR DELETE USING (auth.uid() = user_id);
--
--   -- child tables: scope by journey ownership
--   CREATE POLICY journey_stops_all_own ON journey_stops
--     FOR ALL
--     USING (EXISTS (SELECT 1 FROM journeys j
--                    WHERE j.id = journey_stops.journey_id
--                      AND j.user_id = auth.uid()))
--     WITH CHECK (EXISTS (SELECT 1 FROM journeys j
--                         WHERE j.id = journey_stops.journey_id
--                           AND j.user_id = auth.uid()));
--   -- (analogous for journey_location_pings and post_ride_surveys)
-- ---------------------------------------------------------------------
CREATE POLICY journeys_dev_all ON journeys
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY journey_stops_dev_all ON journey_stops
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY journey_location_pings_dev_all ON journey_location_pings
  FOR ALL USING (true) WITH CHECK (true);

-- =====================================================================
-- RPC FUNCTIONS
--
-- Run as the calling role (SECURITY INVOKER, the default). Under the
-- permissive dev policies above they work for the anon role. The two
-- operations that benefit from a server-side function are:
--   • add_journey_stop — computes the next sequence_order atomically
--   • finish_journey   — single round-trip status + ended_at update
-- All other journey writes (create, ping, cancel, fetch) are done
-- client-side against the tables directly.
-- =====================================================================

-- ---------------------------------------------------------------------
-- add_journey_stop(p_journey_id, p_stop_name, p_latitude, p_longitude)
-- Appends a stop to a journey, assigning the next sequence_order
-- (MAX(sequence_order) + 1, or 1 for the first stop). Returns the
-- inserted journey_stops row.
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
BEGIN
  SELECT COALESCE(MAX(sequence_order), 0) + 1
    INTO v_next_order
    FROM journey_stops
   WHERE journey_id = p_journey_id;

  INSERT INTO journey_stops (journey_id, stop_name, latitude, longitude, sequence_order)
  VALUES (p_journey_id, p_stop_name, p_latitude, p_longitude, v_next_order)
  RETURNING * INTO v_inserted;

  RETURN v_inserted;
END;
$$;

-- Allow anon/authenticated to call it (functions default to PUBLIC EXECUTE,
-- but be explicit so the intent is clear).
GRANT EXECUTE ON FUNCTION add_journey_stop(UUID, VARCHAR, NUMERIC, NUMERIC) TO anon, authenticated;

-- ---------------------------------------------------------------------
-- finish_journey(p_journey_id)
-- Marks a journey as 'completed' and stamps ended_at. Returns the
-- updated journeys row. Idempotent: re-finishing an already-completed
-- journey just refreshes ended_at.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION finish_journey(
  p_journey_id UUID
) RETURNS journeys
LANGUAGE plpgsql
AS $$
DECLARE
  v_updated journeys;
BEGIN
  UPDATE journeys
     SET status   = 'completed',
         ended_at = now()
   WHERE id = p_journey_id
   RETURNING * INTO v_updated;

  RETURN v_updated;
END;
$$;

GRANT EXECUTE ON FUNCTION finish_journey(UUID) TO anon, authenticated;

-- #####################################################################
-- #####################################################################
-- ##                                                                 ##
-- ##   RUN ONLY THE SECTION BELOW IF YOU ALREADY APPLIED AN EARLIER  ##
-- ##   VERSION OF THIS FILE (before post_ride_surveys support).      ##
-- ##                                                                 ##
-- ##   It is also safe on a fresh install — the whole file may be    ##
-- ##   run top-to-bottom. Every statement here is idempotent, so     ##
-- ##   re-running this section alone is safe.                        ##
-- ##                                                                 ##
-- #####################################################################
-- #####################################################################

-- =====================================================================
-- MIGRATION: post_ride_surveys (post-ride survey persistence)
--
-- Enables RLS, grants table privileges, and creates the permissive dev
-- policy for the post_ride_surveys table so the client can insert
-- survey rows keyed by journey_id.
-- =====================================================================

ALTER TABLE post_ride_surveys ENABLE ROW LEVEL SECURITY;

GRANT ALL ON post_ride_surveys TO anon, authenticated;

DROP POLICY IF EXISTS post_ride_surveys_dev_all ON post_ride_surveys;
CREATE POLICY post_ride_surveys_dev_all ON post_ride_surveys
  FOR ALL USING (true) WITH CHECK (true);
