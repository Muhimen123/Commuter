-- =====================================================================
-- COMMUTER APP — DATABASE SCHEMA
-- Derived from: page-by-page feature summary (Onboarding, Auth, Map,
-- Ride Discovery, Profile, Safety)
-- Dialect: PostgreSQL
--
-- NOTE: Per correction, the app now uses Google Maps for both:
--   • Location search / autocomplete (instead of the Photon API)
--   • Routing / polyline generation (instead of OSRM)
-- Any column that stores a route polyline, routing metadata, or a
-- place lookup reflects that.
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ---------------------------------------------------------------------
-- ENUM TYPES
-- ---------------------------------------------------------------------
CREATE TYPE distance_metric_enum      AS ENUM ('km', 'miles');
CREATE TYPE verification_purpose_enum AS ENUM ('signup', 'password_reset');
CREATE TYPE journey_status_enum       AS ENUM ('active', 'completed', 'cancelled');
CREATE TYPE fare_type_enum            AS ENUM ('regular', 'student');
CREATE TYPE bus_status_enum           AS ENUM ('scheduled', 'arriving', 'in_transit', 'delayed', 'cancelled');
CREATE TYPE crowd_level_enum          AS ENUM ('low', 'moderate', 'high', 'full');
CREATE TYPE safety_report_type_enum   AS ENUM ('sos', 'emergency_report');
CREATE TYPE safety_alert_status_enum  AS ENUM ('triggered', 'acknowledged', 'resolved', 'false_alarm');

-- =====================================================================
-- 1. AUTH / ONBOARDING
-- =====================================================================

CREATE TABLE users (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name           VARCHAR(150)  NOT NULL,
    email               VARCHAR(255)  NOT NULL UNIQUE,
    phone_number        VARCHAR(30)   NOT NULL,
    password_hash       TEXT          NOT NULL,
    profile_photo_url   TEXT,
    location_permission_granted BOOLEAN NOT NULL DEFAULT FALSE, -- from Splash Page permission check
    contacts_permission_granted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- Forgot Password / Verify Code flow
CREATE TABLE auth_verification_codes (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    code          VARCHAR(10) NOT NULL,
    purpose       verification_purpose_enum NOT NULL,
    expires_at    TIMESTAMPTZ NOT NULL,
    is_used       BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_verification_codes_user ON auth_verification_codes(user_id);

-- Login session / refresh tokens (mobile app auth)
CREATE TABLE auth_sessions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token   TEXT NOT NULL UNIQUE,
    device_info     TEXT,
    issued_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at      TIMESTAMPTZ NOT NULL,
    revoked_at      TIMESTAMPTZ
);
CREATE INDEX idx_auth_sessions_user ON auth_sessions(user_id);

-- =====================================================================
-- 2. PROFILE & SETTINGS
-- =====================================================================

CREATE TABLE user_settings (
    user_id                      UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    dark_mode_enabled            BOOLEAN NOT NULL DEFAULT FALSE,
    distance_metric              distance_metric_enum NOT NULL DEFAULT 'km',
    push_notifications_enabled   BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at                   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Trusted Guardians
CREATE TABLE trusted_contacts (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    contact_name        VARCHAR(150) NOT NULL,
    contact_phone_number VARCHAR(30) NOT NULL,
    linked_user_id      UUID REFERENCES users(id) ON DELETE SET NULL, -- non-null if the contact is also a registered app user
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_trusted_contacts_owner ON trusted_contacts(owner_user_id);

-- =====================================================================
-- 3. RIDE DISCOVERY (Buses / Routes)
-- =====================================================================

CREATE TABLE routes (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    route_number        VARCHAR(30) NOT NULL,
    route_name          VARCHAR(150) NOT NULL,
    average_fare        NUMERIC(10,2),
    safety_score        NUMERIC(3,2),          -- e.g. 0.00–5.00, shown on Bus Profile / Discovery
    start_point_name    VARCHAR(255),
    start_place_id      VARCHAR(255),          -- Google Places place_id, if resolved via Google Maps search
    start_latitude      NUMERIC(9,6),
    start_longitude     NUMERIC(9,6),
    end_point_name      VARCHAR(255),
    end_place_id        VARCHAR(255),
    end_latitude        NUMERIC(9,6),
    end_longitude       NUMERIC(9,6),
    route_polyline      TEXT,                  -- encoded polyline, sourced from Google Maps Directions API
    current_status      bus_status_enum NOT NULL DEFAULT 'scheduled',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Stoppage Points (expandable list on Bus Profile Page)
CREATE TABLE route_stops (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    route_id        UUID NOT NULL REFERENCES routes(id) ON DELETE CASCADE,
    stop_name       VARCHAR(255) NOT NULL,
    latitude        NUMERIC(9,6) NOT NULL,
    longitude       NUMERIC(9,6) NOT NULL,
    sequence_order  INTEGER NOT NULL
);
CREATE INDEX idx_route_stops_route ON route_stops(route_id);

-- Community Feed (reviews/ratings on Bus Profile Page)
CREATE TABLE route_reviews (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    route_id      UUID NOT NULL REFERENCES routes(id) ON DELETE CASCADE,
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating        NUMERIC(2,1) NOT NULL CHECK (rating BETWEEN 0 AND 5),
    review_text   TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_route_reviews_route ON route_reviews(route_id);

-- Crowd Level (real-time/recent crowd density, e.g. "Moderate crowd at previous stop")
CREATE TABLE crowd_level_reports (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    route_id            UUID NOT NULL REFERENCES routes(id) ON DELETE CASCADE,
    stop_id             UUID REFERENCES route_stops(id) ON DELETE SET NULL,
    crowd_level         crowd_level_enum NOT NULL,
    reported_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    reported_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_crowd_reports_route ON crowd_level_reports(route_id);

-- =====================================================================
-- 4. MAP & JOURNEY (Core Feature)
-- =====================================================================

CREATE TABLE journeys (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id                 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    route_id                UUID REFERENCES routes(id) ON DELETE SET NULL, -- null if a custom/non-bus journey
    origin_name             VARCHAR(255),
    origin_place_id         VARCHAR(255),       -- Google Places place_id from location search
    origin_latitude         NUMERIC(9,6) NOT NULL,
    origin_longitude        NUMERIC(9,6) NOT NULL,
    destination_name        VARCHAR(255),
    destination_place_id    VARCHAR(255),
    destination_latitude    NUMERIC(9,6),
    destination_longitude   NUMERIC(9,6),
    route_polyline          TEXT,               -- drafted/drawn route, sourced from Google Maps Directions API
    status                  journey_status_enum NOT NULL DEFAULT 'active',
    live_tracking_enabled   BOOLEAN NOT NULL DEFAULT TRUE,
    distance_km             NUMERIC(8,2),
    started_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    ended_at                TIMESTAMPTZ,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_journeys_user ON journeys(user_id);
CREATE INDEX idx_journeys_status ON journeys(status);

-- In-Journey Controls: stops added dynamically after journey starts
CREATE TABLE journey_stops (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    journey_id      UUID NOT NULL REFERENCES journeys(id) ON DELETE CASCADE,
    stop_name       VARCHAR(255),
    latitude        NUMERIC(9,6) NOT NULL,
    longitude       NUMERIC(9,6) NOT NULL,
    sequence_order  INTEGER NOT NULL,
    added_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_journey_stops_journey ON journey_stops(journey_id);

-- Live location pings while "Live tracking" mode is active
CREATE TABLE journey_location_pings (
    id          BIGSERIAL PRIMARY KEY,
    journey_id  UUID NOT NULL REFERENCES journeys(id) ON DELETE CASCADE,
    latitude    NUMERIC(9,6) NOT NULL,
    longitude   NUMERIC(9,6) NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_journey_pings_journey ON journey_location_pings(journey_id, recorded_at);

-- Post-Ride Survey (fare, ride rating, safety rating, feedback)
CREATE TABLE post_ride_surveys (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    journey_id      UUID NOT NULL UNIQUE REFERENCES journeys(id) ON DELETE CASCADE,
    fare_paid       NUMERIC(10,2),
    fare_type       fare_type_enum NOT NULL DEFAULT 'regular',
    ride_rating     NUMERIC(2,1) CHECK (ride_rating BETWEEN 0 AND 5),
    safety_rating   NUMERIC(2,1) CHECK (safety_rating BETWEEN 0 AND 5),
    feedback_text   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Safety Heatmap layer (toggleable historical safety data points on Map Page)
CREATE TABLE safety_heatmap_points (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    latitude            NUMERIC(9,6) NOT NULL,
    longitude           NUMERIC(9,6) NOT NULL,
    safety_score        NUMERIC(3,2) NOT NULL,  -- drives the color-coded legend
    source_incident_id  UUID,                   -- optional link to incident_reports.id (see below)
    recorded_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_heatmap_points_location ON safety_heatmap_points(latitude, longitude);

-- =====================================================================
-- 5. SAFETY
-- =====================================================================

-- Granular Incident Report (Report Page sliders + notes)
CREATE TABLE incident_reports (
    id                          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id                     UUID REFERENCES users(id) ON DELETE SET NULL,
    location_text               VARCHAR(255),   -- manual entry fallback if geolocation fails
    latitude                    NUMERIC(9,6),
    longitude                   NUMERIC(9,6),
    lighting_rating             SMALLINT NOT NULL CHECK (lighting_rating BETWEEN 1 AND 5),
    public_visibility_rating    SMALLINT NOT NULL CHECK (public_visibility_rating BETWEEN 1 AND 5),
    crowd_density_rating        SMALLINT NOT NULL CHECK (crowd_density_rating BETWEEN 1 AND 5),
    security_presence_rating    SMALLINT NOT NULL CHECK (security_presence_rating BETWEEN 1 AND 5),
    harassment_frequency_rating SMALLINT NOT NULL CHECK (harassment_frequency_rating BETWEEN 1 AND 5),
    theft_frequency_rating      SMALLINT NOT NULL CHECK (theft_frequency_rating BETWEEN 1 AND 5),
    overall_safety_rating       SMALLINT NOT NULL CHECK (overall_safety_rating BETWEEN 1 AND 5),
    notes                       TEXT,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_incident_reports_user ON incident_reports(user_id);

-- Link heatmap points back to their source incident report
ALTER TABLE safety_heatmap_points
    ADD CONSTRAINT fk_heatmap_source_incident
    FOREIGN KEY (source_incident_id) REFERENCES incident_reports(id) ON DELETE SET NULL;

-- SOS / Emergency quick actions
CREATE TABLE safety_alerts (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    journey_id      UUID REFERENCES journeys(id) ON DELETE SET NULL,
    report_type     safety_report_type_enum NOT NULL DEFAULT 'sos',
    latitude        NUMERIC(9,6),
    longitude       NUMERIC(9,6),
    status          safety_alert_status_enum NOT NULL DEFAULT 'triggered',
    triggered_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    resolved_at     TIMESTAMPTZ
);
CREATE INDEX idx_safety_alerts_user ON safety_alerts(user_id);

-- Live Location Sharing (Safety Page: "sharing with" / "shared with me")
CREATE TABLE location_shares (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sharer_user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trusted_contact_id  UUID REFERENCES trusted_contacts(id) ON DELETE SET NULL,
    recipient_user_id   UUID REFERENCES users(id) ON DELETE SET NULL, -- populated when the contact is a registered app user
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    started_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    ended_at            TIMESTAMPTZ
);
CREATE INDEX idx_location_shares_sharer ON location_shares(sharer_user_id);
CREATE INDEX idx_location_shares_recipient ON location_shares(recipient_user_id);

-- =====================================================================
-- NOTES
-- =====================================================================
-- • Ride History Page reads from `journeys` (status = 'completed') joined
--   with `post_ride_surveys`, no separate table needed.
-- • Profile analytics (Transit Intelligence, Financial Spending, Commute
--   Analytics, Safety Metrics) are derived/aggregated from `journeys`,
--   `post_ride_surveys`, and `incident_reports` rather than stored directly.
-- • "Survey History" on the Safety Page reads from `incident_reports`
--   filtered by user_id.
-- • Any route/polyline field (`routes.route_polyline`,
--   `journeys.route_polyline`) is populated via the Google Maps
--   Directions API. Any `*_place_id` field is populated via Google
--   Places (search/autocomplete), replacing the previous OSRM + Photon
--   integrations entirely.
-- =====================================================================
