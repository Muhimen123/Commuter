-- =====================================================================
-- FIX: Mutual Deletion and Duplicate Cleanup
-- =====================================================================

-- 1. Create RPC for mutual contact removal
-- This ensures that when A removes B, B also removes A.
CREATE OR REPLACE FUNCTION remove_trusted_contact(p_contact_id UUID)
RETURNS VOID AS $$
DECLARE
    v_row RECORD;
BEGIN
    -- Find the contact row I want to delete
    SELECT * INTO v_row FROM trusted_contacts WHERE id = p_contact_id AND owner_user_id = auth.uid();

    IF v_row IS NOT NULL THEN
        -- Delete the reciprocal row (where the other person is the owner)
        DELETE FROM trusted_contacts
        WHERE owner_user_id = v_row.linked_user_id
          AND linked_user_id = auth.uid();

        -- Delete my own row
        DELETE FROM trusted_contacts WHERE id = p_contact_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION remove_trusted_contact(UUID) TO authenticated;
