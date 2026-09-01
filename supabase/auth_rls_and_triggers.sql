-- =====================================================================
-- COMMUTER APP — AUTH RLS, GRANTS & AUTOMATIC PROFILE TRIGGER
--
-- Applies to:
--   users, user_settings, auth_sessions
--
-- Instructions: Run this entire script in your Supabase SQL Editor.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Enable Row Level Security
-- ---------------------------------------------------------------------
ALTER TABLE users         ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_sessions ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------
-- 2. Table-level grants to anon + authenticated roles
-- ---------------------------------------------------------------------
GRANT ALL ON users         TO anon, authenticated, service_role;
GRANT ALL ON user_settings TO anon, authenticated, service_role;
GRANT ALL ON auth_sessions TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------
-- 3. RLS Policies (Allow reads and writes)
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS users_all_policy ON users;
CREATE POLICY users_all_policy ON users
  FOR ALL
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS user_settings_all_policy ON user_settings;
CREATE POLICY user_settings_all_policy ON user_settings
  FOR ALL
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS auth_sessions_all_policy ON auth_sessions;
CREATE POLICY auth_sessions_all_policy ON auth_sessions
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- ---------------------------------------------------------------------
-- 4. Automatic Trigger: Sync Supabase auth.users -> public.users
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (
    id,
    full_name,
    email,
    phone_number,
    password_hash,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'phone_number', ''),
    'supabase_auth',
    now(),
    now()
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    phone_number = CASE 
      WHEN EXCLUDED.phone_number <> '' THEN EXCLUDED.phone_number 
      ELSE public.users.phone_number 
    END,
    updated_at = now();

  INSERT INTO public.user_settings (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$;

-- Drop trigger if already exists and recreate
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ---------------------------------------------------------------------
-- 5. Backfill any existing auth.users into public.users
-- ---------------------------------------------------------------------
INSERT INTO public.users (
  id,
  full_name,
  email,
  phone_number,
  password_hash,
  created_at,
  updated_at
)
SELECT 
  id, 
  COALESCE(raw_user_meta_data->>'full_name', split_part(email, '@', 1)), 
  email, 
  COALESCE(raw_user_meta_data->>'phone_number', ''), 
  'supabase_auth', 
  created_at, 
  now()
FROM auth.users
ON CONFLICT (id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  email = EXCLUDED.email,
  phone_number = CASE 
    WHEN EXCLUDED.phone_number <> '' THEN EXCLUDED.phone_number 
    ELSE public.users.phone_number 
  END,
  updated_at = now();

INSERT INTO public.user_settings (user_id)
SELECT id FROM auth.users
ON CONFLICT (user_id) DO NOTHING;

-- ---------------------------------------------------------------------
-- 6. Automatic Trigger: Delete public.users when auth.users is deleted
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_auth_user_deleted()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM public.users WHERE id = OLD.id;
  RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_deleted ON auth.users;
CREATE TRIGGER on_auth_user_deleted
  AFTER DELETE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_auth_user_deleted();

-- ---------------------------------------------------------------------
-- 7. Automatic Trigger: Delete auth.users when public.users is deleted
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_public_user_deleted()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  DELETE FROM auth.users WHERE id = OLD.id;
  RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS on_public_user_deleted ON public.users;
CREATE TRIGGER on_public_user_deleted
  AFTER DELETE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_public_user_deleted();

