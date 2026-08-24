-- =====================================================================
-- COMMUTER APP — INCIDENT REPORTS (RLS + grants)
--
-- Additive to schema.sql. Applies ONLY to: incident_reports
--
-- AUTH STATUS: client auth is mocked (no real Supabase Auth session yet,
-- see journey_rls_and_rpcs.sql for the same situation on journeys).
-- RLS here is intentionally PERMISSIVE so the dev user id
-- ('00000000-0000-0000-0000-000000000001', see seed.sql) — or an
-- anonymous reporter (user_id IS NULL) — can insert via the anon key.
-- When real Supabase Auth lands, replace the *_dev_all policies with
-- auth-uid-scoped ones (see TODO block below).
-- =====================================================================

ALTER TABLE incident_reports ENABLE ROW LEVEL SECURITY;

GRANT ALL ON incident_reports TO anon, authenticated;

-- ---------------------------------------------------------------------
-- PERMISSIVE DEV POLICY (allow everything)
-- TODO(real-auth): drop this and replace with, e.g.:
--
--   CREATE POLICY incident_reports_insert_own ON incident_reports
--     FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);
--   CREATE POLICY incident_reports_select_own ON incident_reports
--     FOR SELECT USING (auth.uid() = user_id);
--
-- (Reports are safety-sensitive community data — consider whether other
-- users should be able to read all reports for heatmap/history purposes,
-- vs. only their own. The Safety Page's heatmap likely wants broader
-- SELECT access than a plain "own rows only" policy would allow.)
-- ---------------------------------------------------------------------
CREATE POLICY incident_reports_dev_all ON incident_reports
  FOR ALL USING (true) WITH CHECK (true);
