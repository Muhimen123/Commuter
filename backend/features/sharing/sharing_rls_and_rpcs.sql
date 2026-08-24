-- =====================================================================
-- COMMUTER APP — LOCATION SHARING BACKEND (RLS + grants + RPC functions)
-- =====================================================================

-- ---------------------------------------------------------------------
-- Schema Migration: Ensure columns exist
-- ---------------------------------------------------------------------
ALTER TABLE location_shares
ADD COLUMN IF NOT EXISTS journey_id UUID REFERENCES journeys(id) ON DELETE SET NULL;

-- ---------------------------------------------------------------------
-- Enable Row Level Security
-- ---------------------------------------------------------------------
ALTER TABLE location_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE trusted_contacts ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------
-- Table-level grants
-- ---------------------------------------------------------------------
GRANT ALL ON location_shares TO anon, authenticated;
GRANT ALL ON trusted_contacts TO anon, authenticated;

-- ---------------------------------------------------------------------
-- RLS Policies (with DROP safety)
-- ---------------------------------------------------------------------
DO $$ BEGIN
    DROP POLICY IF EXISTS contacts_owner_all ON trusted_contacts;
    CREATE POLICY contacts_owner_all ON trusted_contacts
      FOR ALL USING (auth.uid() = owner_user_id);

    DROP POLICY IF EXISTS shares_sharer_all ON location_shares;
    CREATE POLICY shares_sharer_all ON location_shares
      FOR ALL USING (auth.uid() = sharer_user_id);

    DROP POLICY IF EXISTS shares_recipient_select ON location_shares;
    CREATE POLICY shares_recipient_select ON location_shares
      FOR SELECT USING (auth.uid() = recipient_user_id);
END $$;

-- ---------------------------------------------------------------------
-- RPC FUNCTIONS
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- start_sharing_location(p_sharer_user_id, p_journey_id, p_recipient_user_id, p_trusted_contact_id)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION start_sharing_location(
  p_sharer_user_id UUID,
  p_journey_id UUID,
  p_recipient_user_id UUID DEFAULT NULL,
  p_trusted_contact_id UUID DEFAULT NULL
) RETURNS location_shares
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_inserted location_shares;
BEGIN
  -- Deactivate existing active shares for the same sharer to prevent multiple active sessions
  UPDATE location_shares
     SET is_active = FALSE,
         ended_at = now()
   WHERE sharer_user_id = p_sharer_user_id
     AND is_active = TRUE;

  INSERT INTO location_shares (
    sharer_user_id,
    journey_id,
    recipient_user_id,
    trusted_contact_id,
    is_active
  )
  VALUES (
    p_sharer_user_id,
    p_journey_id,
    p_recipient_user_id,
    p_trusted_contact_id,
    TRUE
  )
  RETURNING * INTO v_inserted;

  RETURN v_inserted;
END;
$$;

GRANT EXECUTE ON FUNCTION start_sharing_location(UUID, UUID, UUID, UUID) TO anon, authenticated;

-- ---------------------------------------------------------------------
-- stop_sharing_location(p_share_id)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION stop_sharing_location(
  p_share_id UUID
) RETURNS location_shares
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_updated location_shares;
BEGIN
  UPDATE location_shares
     SET is_active = FALSE,
         ended_at = now()
   WHERE id = p_share_id
     -- Ensure only the owner can stop it if called via RPC
     AND (sharer_user_id = auth.uid() OR auth.uid() IS NULL)
   RETURNING * INTO v_updated;

  RETURN v_updated;
END;
$$;

GRANT EXECUTE ON FUNCTION stop_sharing_location(UUID) TO anon, authenticated;

-- ---------------------------------------------------------------------
-- add_trusted_contact_linked(p_name, p_phone)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION add_trusted_contact_linked(
    p_name VARCHAR,
    p_phone VARCHAR
) RETURNS trusted_contacts
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_linked_id UUID;
    v_contact   trusted_contacts;
BEGIN
    -- Try to find a registered user with this phone number
    SELECT id INTO v_linked_id FROM users WHERE phone_number = p_phone LIMIT 1;

    INSERT INTO trusted_contacts (owner_user_id, contact_name, contact_phone_number, linked_user_id)
    VALUES (auth.uid(), p_name, p_phone, v_linked_id)
    RETURNING * INTO v_contact;

    RETURN v_contact;
END;
$$;

GRANT EXECUTE ON FUNCTION add_trusted_contact_linked(VARCHAR, VARCHAR) TO authenticated;

-- ---------------------------------------------------------------------
-- VIEW: active_shares_with_me
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS active_shares_with_me;
CREATE OR REPLACE VIEW active_shares_with_me AS
SELECT
    ls.id as share_id,
    u.id as sharer_id,
    u.full_name as sharer_name,
    u.profile_photo_url as sharer_photo,
    j.id as journey_id,
    j.status as journey_status,
    j.destination_name,
    lp.latitude as last_lat,
    lp.longitude as last_lng,
    lp.recorded_at as last_ping_at
FROM location_shares ls
JOIN users u ON u.id = ls.sharer_user_id
JOIN journeys j ON j.id = ls.journey_id
LEFT JOIN LATERAL (
    -- Get the most recent ping for this journey
    SELECT latitude, longitude, recorded_at
    FROM journey_location_pings
    WHERE journey_id = j.id
    ORDER BY recorded_at DESC
    LIMIT 1
) lp ON TRUE
WHERE ls.recipient_user_id = auth.uid()
  AND ls.is_active = TRUE
  AND j.status = 'active';

GRANT SELECT ON active_shares_with_me TO authenticated;
