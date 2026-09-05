-- ---------------------------------------------------------------------
-- 1. New enum for the ride category
-- ---------------------------------------------------------------------
CREATE TYPE transit_mode_enum AS ENUM ('bus', 'metro', 'train');

-- ---------------------------------------------------------------------
-- 2. Tag every route with its category
--    Existing rows default to 'bus' so current data stays valid.
-- ---------------------------------------------------------------------
ALTER TABLE routes
    ADD COLUMN transit_mode transit_mode_enum NOT NULL DEFAULT 'bus';

CREATE INDEX idx_routes_transit_mode ON routes(transit_mode);

-- ---------------------------------------------------------------------
-- 3. Rename bus_status_enum -> transit_status_enum
--    Values (scheduled/arriving/in_transit/delayed/cancelled) already
--    apply to metro/train; this is a naming fix, no data changes.
-- ---------------------------------------------------------------------
ALTER TYPE bus_status_enum RENAME TO transit_status_enum;

-- ---------------------------------------------------------------------
-- 4. Mode-specific metadata
--    Nullable so bus rows (which won't use them) are unaffected.
--    line_code/line_color are typically used by metro/train (e.g.
--    "Red Line" / #E4002B); platform_number is used at stops for
--    metro/train boarding.
-- ---------------------------------------------------------------------
ALTER TABLE routes
    ADD COLUMN line_code  VARCHAR(30),
    ADD COLUMN line_color VARCHAR(7);   -- hex color, e.g. '#E4002B'

ALTER TABLE route_stops
    ADD COLUMN platform_number VARCHAR(10);
