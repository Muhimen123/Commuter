-- ============================================================
-- METRO: Dhaka Metro Rail — MRT Line-6 (Uttara North ↔ Motijheel)
-- Source: https://en.wikipedia.org/wiki/MRT_Line_6
--         https://www.bdrailwayinfo.org/metro-rail/fare
--
-- Station names/order and the line itself are real; coordinates are
-- reasonable approximations (not surveyed), and average_fare reflects
-- the published full-line fare (৳100) rather than a live fare API pull.
-- ============================================================

INSERT INTO routes (
    id, route_number, route_name, average_fare, safety_score,
    start_point_name, start_latitude, start_longitude,
    end_point_name, end_latitude, end_longitude,
    current_status, transit_mode, line_code, line_color
) VALUES (
    '11111111-1111-1111-1111-111111111111',
    'MRT-6', 'MRT Line-6 (Uttara North – Motijheel)', 100.00, 4.80,
    'Uttara North', 23.875900, 90.379500,
    'Motijheel', 23.733300, 90.417200,
    'scheduled', 'metro', 'MRT-6', '#00A651'
);

INSERT INTO route_stops (route_id, stop_name, latitude, longitude, sequence_order, platform_number) VALUES
('11111111-1111-1111-1111-111111111111', 'Uttara North',          23.875900, 90.379500, 1,  '1'),
('11111111-1111-1111-1111-111111111111', 'Uttara Center',         23.865900, 90.379800, 2,  '1'),
('11111111-1111-1111-1111-111111111111', 'Uttara South',          23.855800, 90.379800, 3,  '1'),
('11111111-1111-1111-1111-111111111111', 'Pallabi',               23.821800, 90.365400, 4,  '1'),
('11111111-1111-1111-1111-111111111111', 'Mirpur 11',             23.816300, 90.365400, 5,  '1'),
('11111111-1111-1111-1111-111111111111', 'Mirpur 10',             23.806400, 90.368800, 6,  '1'),
('11111111-1111-1111-1111-111111111111', 'Kazipara',              23.798500, 90.371200, 7,  '1'),
('11111111-1111-1111-1111-111111111111', 'Shewrapara',            23.792000, 90.373400, 8,  '1'),
('11111111-1111-1111-1111-111111111111', 'Agargaon',              23.778300, 90.377800, 9,  '1'),
('11111111-1111-1111-1111-111111111111', 'Bijoy Sarani',          23.762200, 90.392700, 10, '1'),
('11111111-1111-1111-1111-111111111111', 'Farmgate',              23.756600, 90.389800, 11, '1'),
('11111111-1111-1111-1111-111111111111', 'Kawran Bazar',          23.750800, 90.392500, 12, '1'),
('11111111-1111-1111-1111-111111111111', 'Shahbag',               23.738600, 90.395800, 13, '1'),
('11111111-1111-1111-1111-111111111111', 'Dhaka University',      23.733300, 90.392800, 14, '1'),
('11111111-1111-1111-1111-111111111111', 'Bangladesh Secretariat',23.733300, 90.407900, 15, '1'),
('11111111-1111-1111-1111-111111111111', 'Motijheel',             23.733300, 90.417200, 16, '1');

-- ============================================================
-- TRAIN: Bangladesh Railway — sample intercity services from Kamalapur
-- Source: https://www.bdrailwayinfo.org/  (route names, station pairs,
-- approximate distance/duration)
--
-- Route names, station pairs, and terminus stations are real; intermediate
-- stop coordinates are approximate midpoints (not exact station GPS), and
-- average_fare is an approximate figure, not pulled from a live fare chart.
-- ============================================================

-- Sundarban Express (725/726): Dhaka (Kamalapur) ↔ Khulna, ~383 km, ~7h30m
INSERT INTO routes (
    id, route_number, route_name, average_fare, safety_score,
    start_point_name, start_latitude, start_longitude,
    end_point_name, end_latitude, end_longitude,
    current_status, transit_mode, line_code, line_color
) VALUES (
    '22222222-2222-2222-2222-222222222221',
    '725/726', 'Sundarban Express (Dhaka – Khulna)', 505.00, 4.50,
    'Kamalapur Railway Station', 23.733100, 90.426500,
    'Khulna Railway Station', 22.818100, 89.550000,
    'scheduled', 'train', 'BR-SUNDARBAN', '#C8102E'
);

INSERT INTO route_stops (route_id, stop_name, latitude, longitude, sequence_order, platform_number) VALUES
('22222222-2222-2222-2222-222222222221', 'Kamalapur',  23.733100, 90.426500, 1, '4'),
('22222222-2222-2222-2222-222222222221', 'Jamtoil',    24.019000, 89.983000, 2, NULL),
('22222222-2222-2222-2222-222222222221', 'Ishwardi',   24.135000, 89.083000, 3, NULL),
('22222222-2222-2222-2222-222222222221', 'Kushtia',    23.901000, 89.121000, 4, NULL),
('22222222-2222-2222-2222-222222222221', 'Khulna',     22.818100, 89.550000, 5, '1');

-- Upaban Express (739/740): Dhaka (Kamalapur) ↔ Sylhet, ~319 km, ~7h
INSERT INTO routes (
    id, route_number, route_name, average_fare, safety_score,
    start_point_name, start_latitude, start_longitude,
    end_point_name, end_latitude, end_longitude,
    current_status, transit_mode, line_code, line_color
) VALUES (
    '22222222-2222-2222-2222-222222222222',
    '739/740', 'Upaban Express (Dhaka – Sylhet)', 450.00, 4.60,
    'Kamalapur Railway Station', 23.733100, 90.426500,
    'Sylhet Railway Station', 24.897400, 91.868000,
    'scheduled', 'train', 'BR-UPABAN', '#0033A0'
);

INSERT INTO route_stops (route_id, stop_name, latitude, longitude, sequence_order, platform_number) VALUES
('22222222-2222-2222-2222-222222222222', 'Kamalapur',    23.733100, 90.426500, 1, '3'),
('22222222-2222-2222-2222-222222222222', 'Bhairab Bazar',24.053000, 90.973000, 2, NULL),
('22222222-2222-2222-2222-222222222222', 'Ashuganj',     24.045000, 91.008000, 3, NULL),
('22222222-2222-2222-2222-222222222222', 'Sylhet',       24.897400, 91.868000, 4, '1');

-- ============================================================
-- BUS: sample Dhaka bus routes (transit_mode defaults to 'bus')
-- Fictional operators/routes, styled like the existing mock data
-- (Turag Transport, Mirpur Link, etc.) — not sourced from a real registry.
-- ============================================================

INSERT INTO routes (
    id, route_number, route_name, average_fare, safety_score,
    start_point_name, start_latitude, start_longitude,
    end_point_name, end_latitude, end_longitude,
    current_status, transit_mode
) VALUES
(
    '33333333-3333-3333-3333-333333333331',
    '42', 'Turag Transport', 35.00, 4.90,
    'Uttara', 23.868000, 90.399000,
    'Motijheel', 23.733300, 90.417200,
    'scheduled', 'bus'
),
(
    '33333333-3333-3333-3333-333333333332',
    '15', 'Mirpur Link', 25.00, 4.60,
    'Mirpur 10', 23.806400, 90.368800,
    'Kakrail', 23.737800, 90.408500,
    'scheduled', 'bus'
),
(
    '33333333-3333-3333-3333-333333333333',
    '88', 'Balaka Paribahan', 40.00, 4.95,
    'Badda', 23.780900, 90.426700,
    'Gulshan 1', 23.780800, 90.416300,
    'delayed', 'bus'
);

INSERT INTO route_stops (route_id, stop_name, latitude, longitude, sequence_order) VALUES
('33333333-3333-3333-3333-333333333331', 'Uttara',    23.868000, 90.399000, 1),
('33333333-3333-3333-3333-333333333331', 'Farmgate',  23.756600, 90.389800, 2),
('33333333-3333-3333-3333-333333333331', 'Motijheel', 23.733300, 90.417200, 3),

('33333333-3333-3333-3333-333333333332', 'Mirpur 10', 23.806400, 90.368800, 1),
('33333333-3333-3333-3333-333333333332', 'Kazipara',  23.798500, 90.371200, 2),
('33333333-3333-3333-3333-333333333332', 'Kakrail',   23.737800, 90.408500, 3),

('33333333-3333-3333-3333-333333333333', 'Badda',     23.780900, 90.426700, 1),
('33333333-3333-3333-3333-333333333333', 'Gulshan 1', 23.780800, 90.416300, 2);
