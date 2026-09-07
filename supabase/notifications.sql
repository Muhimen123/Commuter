-- =====================================================================
-- COMMUTER APP — NOTIFICATION SYSTEM
-- =====================================================================

CREATE TABLE IF NOT EXISTS notifications (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type        VARCHAR(50) NOT NULL, -- 'contact_invite', 'location_share', 'sos_alert'
    title       TEXT NOT NULL,
    content     TEXT NOT NULL,
    payload     JSONB, -- contains extra data like sender_id, journey_id, etc.
    is_read     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY notifications_owner_all ON notifications
    FOR ALL USING (auth.uid() = user_id);

GRANT ALL ON notifications TO authenticated;

-- ---------------------------------------------------------------------
-- TRIGGERS
-- ---------------------------------------------------------------------

-- 1. Trigger for Contact Invites
CREATE OR REPLACE FUNCTION notify_contact_invite()
RETURNS TRIGGER AS $$
DECLARE
    v_sender_name TEXT;
BEGIN
    SELECT full_name INTO v_sender_name FROM users WHERE id = NEW.owner_user_id;

    -- Notify when an invite is created OR when a rejected invite is reset to pending
    IF NEW.status = 'pending' AND NEW.linked_user_id IS NOT NULL THEN
        INSERT INTO notifications (user_id, type, title, content, payload)
        VALUES (
            NEW.linked_user_id,
            'contact_invite',
            'New Guardian Request',
            v_sender_name || ' wants to add you as a trusted guardian.',
            jsonb_build_object(
                'sender_id', NEW.owner_user_id,
                'sender_name', v_sender_name,
                'invite_id', NEW.id
            )
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_notify_contact_invite ON trusted_contacts;
CREATE TRIGGER tr_notify_contact_invite
    AFTER INSERT OR UPDATE OF status ON trusted_contacts
    FOR EACH ROW EXECUTE FUNCTION notify_contact_invite();


-- 2. Trigger for Location Sharing
CREATE OR REPLACE FUNCTION notify_location_share()
RETURNS TRIGGER AS $$
DECLARE
    v_sharer_name TEXT;
    v_lat NUMERIC;
    v_lng NUMERIC;
BEGIN
    SELECT full_name INTO v_sharer_name FROM users WHERE id = NEW.sharer_user_id;

    -- Only notify when sharing becomes active
    IF NEW.is_active = TRUE AND (OLD.is_active IS NULL OR OLD.is_active = FALSE) AND NEW.recipient_user_id IS NOT NULL THEN

        -- Try to get the latest ping for initial location preview
        SELECT latitude, longitude INTO v_lat, v_lng
        FROM journey_location_pings
        WHERE user_id = NEW.sharer_user_id
        ORDER BY recorded_at DESC LIMIT 1;

        INSERT INTO notifications (user_id, type, title, content, payload)
        VALUES (
            NEW.recipient_user_id,
            'location_share',
            'Live Location Shared',
            v_sharer_name || ' is now sharing their live location with you.',
            jsonb_build_object(
                'sharer_id', NEW.sharer_user_id,
                'sender_name', v_sharer_name,
                'share_id', NEW.id,
                'journey_id', NEW.journey_id,
                'lat', v_lat,
                'lng', v_lng
            )
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_notify_location_share ON location_shares;
CREATE TRIGGER tr_notify_location_share
    AFTER INSERT OR UPDATE OF is_active ON location_shares
    FOR EACH ROW EXECUTE FUNCTION notify_location_share();


-- 3. Trigger for SOS Alerts
CREATE OR REPLACE FUNCTION notify_sos_alert()
RETURNS TRIGGER AS $$
DECLARE
    v_sender_name TEXT;
    v_guardian RECORD;
BEGIN
    SELECT full_name INTO v_sender_name FROM users WHERE id = NEW.user_id;

    -- Notify all accepted trusted contacts
    FOR v_guardian IN
        SELECT linked_user_id
        FROM trusted_contacts
        WHERE owner_user_id = NEW.user_id AND status = 'accepted'
    LOOP
        INSERT INTO notifications (user_id, type, title, content, payload)
        VALUES (
            v_guardian.linked_user_id,
            'sos_alert',
            '🚨 EMERGENCY SOS 🚨',
            v_sender_name || ' HAS TRIGGERED AN EMERGENCY SOS!',
            jsonb_build_object(
                'sender_id', NEW.user_id,
                'sender_name', v_sender_name,
                'alert_id', NEW.id,
                'lat', NEW.latitude,
                'lng', NEW.longitude
            )
        );
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_notify_sos_alert ON safety_alerts;
CREATE TRIGGER tr_notify_sos_alert
    AFTER INSERT ON safety_alerts
    FOR EACH ROW EXECUTE FUNCTION notify_sos_alert();

-- NOTE: To enable "Off-App" Push Notifications (FCM):
-- You would add a webhook to the 'notifications' table that calls
-- a Supabase Edge Function. That function would then use the Firebase
-- Admin SDK to send a push message to the user's registered FCM tokens
-- stored in an 'fcm_tokens' table.
