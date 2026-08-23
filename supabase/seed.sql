-- =====================================================================
-- COMMUTER APP — DEV SEED
--
-- Minimal `users` + `user_settings` rows so journeys.user_id resolves.
-- The mocked client AuthNotifier (frontend/lib/features/auth/domain/
-- auth_notifier.dart) uses this fixed id: 00000000-0000-0000-0000-000000000001
--
-- Run with a privileged role (service_role / postgres), NOT the anon key.
--
-- TODO(real-auth): DELETE this file once Supabase Auth is wired in and the
-- client resolves user_id from the real auth session.
-- =====================================================================

INSERT INTO users (
  id, full_name, email, phone_number, password_hash,
  location_permission_granted, contacts_permission_granted
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Commuter Dev User',
  'dev@commuter.app',
  '+10000000000',
  'dev-no-hash',          -- not used for auth; placeholder only
  TRUE,
  TRUE
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO user_settings (user_id)
VALUES ('00000000-0000-0000-0000-000000000001')
ON CONFLICT (user_id) DO NOTHING;
