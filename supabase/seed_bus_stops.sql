-- ============================================================
-- DENSER BUS STOP LISTS for the three seeded bus routes in
-- seed_metro_train.sql (Turag Transport 42, Mirpur Link 15,
-- Balaka Paribahan 88).
--
-- Those routes originally had only 2-3 stops each — enough to identify
-- the route, but too coarse for the transit itinerary planner
-- (frontend/lib/features/map/domain/transit_planner.dart) to find
-- realistic board/alight points or transfers. This adds intermediate
-- stops along each route's real corridor, and — for routes 42 and 15,
-- which run the same corridor as MRT Line-6 — places several stops
-- within ~250m of the matching MRT-6 station so a bus <-> metro transfer
-- there is cheap (the planner has no distance cap, but a close transfer
-- costs less than a far one and so is preferred).
--
-- Station/stop names and corridors are real; exact coordinates are
-- approximations (not surveyed), consistent with the rest of this file's
-- seed data. Idempotent — safe to re-run.
-- ============================================================

DELETE FROM route_stops WHERE route_id IN (
    '33333333-3333-3333-3333-333333333331', -- 42 Turag Transport
    '33333333-3333-3333-3333-333333333332', -- 15 Mirpur Link
    '33333333-3333-3333-3333-333333333333'  -- 88 Balaka Paribahan
);

-- ------------------------------------------------------------
-- Route 42 (Turag Transport): Uttara -> Motijheel via Mirpur Road.
-- Parallels MRT-6 almost the whole way; stops sit ~250-300m off each
-- matching MRT-6 station, with the shared Motijheel terminus exact.
-- ------------------------------------------------------------
INSERT INTO route_stops (route_id, stop_name, latitude, longitude, sequence_order) VALUES
('33333333-3333-3333-3333-333333333331', 'Uttara',        23.868000, 90.399000, 1),
('33333333-3333-3333-3333-333333333331', 'Mirpur 10',     23.808000, 90.370700, 2),
('33333333-3333-3333-3333-333333333331', 'Kazipara',      23.800000, 90.373000, 3),
('33333333-3333-3333-3333-333333333331', 'Agargaon',      23.780000, 90.379500, 4),
('33333333-3333-3333-3333-333333333331', 'Bijoy Sarani',  23.764000, 90.394500, 5),
('33333333-3333-3333-3333-333333333331', 'Farmgate',      23.758500, 90.391500, 6),
('33333333-3333-3333-3333-333333333331', 'Kawran Bazar',  23.752500, 90.394200, 7),
('33333333-3333-3333-3333-333333333331', 'Shahbag',       23.740300, 90.397500, 8),
('33333333-3333-3333-3333-333333333331', 'Motijheel',     23.733300, 90.417200, 9);

-- ------------------------------------------------------------
-- Route 15 (Mirpur Link): Mirpur 10 -> Kakrail, also tracking MRT-6
-- for its first half before swinging east to Kakrail.
-- ------------------------------------------------------------
INSERT INTO route_stops (route_id, stop_name, latitude, longitude, sequence_order) VALUES
('33333333-3333-3333-3333-333333333332', 'Mirpur 10',     23.806400, 90.368800, 1),
('33333333-3333-3333-3333-333333333332', 'Kazipara',      23.798500, 90.371200, 2),
('33333333-3333-3333-3333-333333333332', 'Shewrapara',    23.793500, 90.375000, 3),
('33333333-3333-3333-3333-333333333332', 'Agargaon',      23.779800, 90.379500, 4),
('33333333-3333-3333-3333-333333333332', 'Bijoy Sarani',  23.763800, 90.394400, 5),
('33333333-3333-3333-3333-333333333332', 'Farmgate',      23.758300, 90.391500, 6),
('33333333-3333-3333-3333-333333333332', 'Kawran Bazar',  23.752300, 90.394200, 7),
('33333333-3333-3333-3333-333333333332', 'Kakrail',       23.737800, 90.408500, 8);

-- ------------------------------------------------------------
-- Route 88 (Balaka Paribahan): Badda -> Gulshan 1, a short local
-- corridor with no metro overlap — deliberately kept walk/bus-only so
-- the planner's all-walk and single-ride cases both stay demonstrable.
-- ------------------------------------------------------------
INSERT INTO route_stops (route_id, stop_name, latitude, longitude, sequence_order) VALUES
('33333333-3333-3333-3333-333333333333', 'Badda',              23.780900, 90.426700, 1),
('33333333-3333-3333-3333-333333333333', 'Merul Badda',        23.780883, 90.424970, 2),
('33333333-3333-3333-3333-333333333333', 'Shahjadpur',         23.780867, 90.423230, 3),
('33333333-3333-3333-3333-333333333333', 'Notun Bazar',        23.780850, 90.421500, 4),
('33333333-3333-3333-3333-333333333333', 'Bashundhara Gate',   23.780833, 90.419770, 5),
('33333333-3333-3333-3333-333333333333', 'Gulshan 2',          23.780817, 90.418030, 6),
('33333333-3333-3333-3333-333333333333', 'Gulshan 1',          23.780800, 90.416300, 7);
