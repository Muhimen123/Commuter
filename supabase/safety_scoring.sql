-- =====================================================================
-- COMMUTER APP — SAFETY SCORING SYSTEM
-- =====================================================================
-- This system calculates a normalized safety score (0.0 to 1.0) based on
-- user-submitted safety surveys (incident_reports).
-- The scoring model is inspired by the SafetiPin methodology and
-- CPTED (Crime Prevention Through Environmental Design) principles.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Safety Score Calculation Function
-- ---------------------------------------------------------------------
-- Weights:
--   - Lighting: 25% (Critical for visibility and deterrent)
--   - Visibility: 20% (Natural surveillance / "eyes on the street")
--   - Crowd Density: 15% (Vitality - more people usually means safer in transit)
--   - Security Presence: 10% (Formal surveillance)
--   - Overall Feeling: 20% (Subjective user perception)
--   - Incident Freedom: 10% (Absence of harassment and theft)
--
-- Formula: Weighted Sum normalized to [0, 1]
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_calculate_safety_score(
    p_lighting SMALLINT,
    p_visibility SMALLINT,
    p_crowd SMALLINT,
    p_security SMALLINT,
    p_harassment SMALLINT,
    p_theft SMALLINT,
    p_overall SMALLINT
) RETURNS NUMERIC(3,2) AS $$
DECLARE
    v_score NUMERIC;
BEGIN
    -- Input validation/clamping (1-5)
    p_lighting   := GREATEST(1, LEAST(5, p_lighting));
    p_visibility := GREATEST(1, LEAST(5, p_visibility));
    p_crowd      := GREATEST(1, LEAST(5, p_crowd));
    p_security   := GREATEST(1, LEAST(5, p_security));
    p_harassment := GREATEST(1, LEAST(5, p_harassment));
    p_theft      := GREATEST(1, LEAST(5, p_theft));
    p_overall    := GREATEST(1, LEAST(5, p_overall));

    -- Weighted sum logic
    -- (Rating - 1) / 4 transforms 1..5 to 0..1
    -- (5 - Rating) / 4 transforms 1..5 to 1..0 (for negative factors)

    v_score := (
        (0.25 * (p_lighting - 1) / 4.0) +
        (0.20 * (p_visibility - 1) / 4.0) +
        (0.15 * (p_crowd - 1) / 4.0) +
        (0.10 * (p_security - 1) / 4.0) +
        (0.20 * (p_overall - 1) / 4.0) +
        (0.05 * (p_harassment - 1) / 4.0) +
        (0.05 * (p_theft - 1) / 4.0)
    );

    RETURN ROUND(v_score::NUMERIC, 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;


-- ---------------------------------------------------------------------
-- 2. Trigger for Incident Reports
-- ---------------------------------------------------------------------
-- Automatically populates safety_heatmap_points whenever a new
-- safety survey/report is submitted.
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tr_fn_update_safety_heatmap()
RETURNS TRIGGER AS $$
BEGIN
    -- Only add to heatmap if location data is present
    IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
        INSERT INTO safety_heatmap_points (
            latitude,
            longitude,
            safety_score,
            source_incident_id,
            recorded_at
        )
        VALUES (
            NEW.latitude,
            NEW.longitude,
            fn_calculate_safety_score(
                NEW.lighting_rating,
                NEW.public_visibility_rating,
                NEW.crowd_density_rating,
                NEW.security_presence_rating,
                NEW.harassment_frequency_rating,
                NEW.theft_frequency_rating,
                NEW.overall_safety_rating
            ),
            NEW.id,
            NEW.created_at
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_update_safety_heatmap ON incident_reports;
CREATE TRIGGER tr_update_safety_heatmap
    AFTER INSERT ON incident_reports
    FOR EACH ROW
    EXECUTE FUNCTION tr_fn_update_safety_heatmap();


-- ---------------------------------------------------------------------
-- 3. Trigger for SOS Alerts (Emergency Reports)
-- ---------------------------------------------------------------------
-- SOS alerts indicate immediate danger, so we add a point with
-- a safety score of 0.0 to the heatmap.
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tr_fn_update_heatmap_from_sos()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
        INSERT INTO safety_heatmap_points (
            latitude,
            longitude,
            safety_score,
            source_incident_id,
            recorded_at
        )
        VALUES (
            NEW.latitude,
            NEW.longitude,
            0.0, -- Maximum danger
            NULL,
            NEW.triggered_at
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_update_heatmap_sos ON safety_alerts;
CREATE TRIGGER tr_update_heatmap_sos
    AFTER INSERT ON safety_alerts
    FOR EACH ROW
    EXECUTE FUNCTION tr_fn_update_heatmap_from_sos();


-- ---------------------------------------------------------------------
-- 4. Backfill Existing Data
-- ---------------------------------------------------------------------
-- Run this once to populate the heatmap with data that was submitted
-- before the triggers were created.
-- ---------------------------------------------------------------------

INSERT INTO safety_heatmap_points (latitude, longitude, safety_score, source_incident_id, recorded_at)
SELECT
    latitude,
    longitude,
    fn_calculate_safety_score(
        lighting_rating,
        public_visibility_rating,
        crowd_density_rating,
        security_presence_rating,
        harassment_frequency_rating,
        theft_frequency_rating,
        overall_safety_rating
    ),
    id,
    created_at
FROM incident_reports
WHERE latitude IS NOT NULL AND longitude IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO safety_heatmap_points (latitude, longitude, safety_score, recorded_at)
SELECT latitude, longitude, 0.0, triggered_at
FROM safety_alerts
WHERE latitude IS NOT NULL AND longitude IS NOT NULL
ON CONFLICT DO NOTHING;


-- ---------------------------------------------------------------------
-- 4. (Optional) Heatmap Aggregation Logic
-- ---------------------------------------------------------------------
-- In case the frontend needs a pre-aggregated view of safety scores
-- for high-performance rendering or cluster labels.
-- ---------------------------------------------------------------------

CREATE OR REPLACE VIEW safety_heatmap_aggregated AS
SELECT
    ROUND(latitude, 4) AS lat_grid,
    ROUND(longitude, 4) AS lng_grid,
    AVG(safety_score) AS avg_score,
    COUNT(*) AS report_count
FROM safety_heatmap_points
GROUP BY 1, 2;
