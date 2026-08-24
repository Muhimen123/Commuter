-- =====================================================================
-- COMMUTER APP — LOCATION SHARING BACKEND (RLS + grants + RPC functions)
-- =====================================================================

-- ---------------------------------------------------------------------
-- Enable Row Level Security
-- ---------------------------------------------------------------------
ALTER TABLE location_shares ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------
-- Table-level grants
-- ---------------------------------------------------------------------
GRANT ALL ON location_shares TO anon, authenticated;

-- ---------------------------------------------------------------------
-- RLS Policies
-- ---------------------------------------------------------------------
-- TODO(real-auth): Use auth.uid() instead of 'true'.
-- For now, allowing all access as per previous implementation style.

CREATE POLICY location_shares_dev_all ON location_shares
  FOR ALL USING (true) WITH CHECK (true);

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
AS $$
DECLARE
  v_inserted location_shares;
BEGIN
  -- Deactivate existing shares for the same journey/user
  UPDATE location_shares
     SET is_active = FALSE,
         ended_at = now()
   WHERE sharer_user_id = p_sharer_user_id
     AND is_active = TRUE;

  INSERT INTO location_shares (sharer_user_id, journey_id, recipient_user_id, trusted_contact_id, is_active)
  VALUES (p_sharer_user_id, p_journey_id, p_recipient_user_id, p_trusted_contact_id, TRUE)
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
AS $$
DECLARE
  v_updated location_shares;
BEGIN
  UPDATE location_shares
     SET is_active = FALSE,
         ended_at = now()
   WHERE id = p_share_id
   RETURNING * INTO v_updated;

  RETURN v_updated;
END;
$$;

GRANT EXECUTE ON FUNCTION stop_sharing_location(UUID) TO anon, authenticated;
