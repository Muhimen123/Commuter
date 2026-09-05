-- =====================================================================
-- SEED SCRIPT: "Data Test" User Profile Statistics
-- =====================================================================
-- Run this script in your Supabase SQL Editor to populate realistic 
-- fake data for a test user named "Data Test".
-- It generates journeys, financials, safety metrics, and trust score
-- data so that your Profile Page displays accurate, aggregated metrics.

DO $$
DECLARE
    v_user_id UUID;
    v_route1_id UUID := 'd83e726a-1111-1111-1111-111111111111';
    v_route2_id UUID := 'd83e726a-2222-2222-2222-222222222222';
    v_route3_id UUID := 'd83e726a-3333-3333-3333-333333333333';
    v_journey1_id UUID := 'e94f837b-1111-1111-1111-111111111111';
    v_journey2_id UUID := 'e94f837b-2222-2222-2222-222222222222';
    v_journey3_id UUID := 'e94f837b-3333-3333-3333-333333333333';
    v_journey4_id UUID := 'e94f837b-4444-4444-4444-444444444444';
    v_journey5_id UUID := 'e94f837b-5555-5555-5555-555555555555';
    v_stop1_id UUID := 'f050948c-1111-1111-1111-111111111111';
BEGIN

    -- 1. Get the actual user ID from Supabase Auth
    SELECT id INTO v_user_id FROM auth.users WHERE email = 'data.test@example.com';
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'User not found! Please sign up in the Commuter app first with email "data.test@example.com" and any password of your choosing.';
    END IF;

    -- Update the public user profile (since the app already inserted a row upon signup)
    UPDATE users SET 
        full_name = 'Data Test', 
        created_at = now() - interval '60 days' 
    WHERE id = v_user_id;

    -- User Settings (The app likely created this on signup, so let's update it)
    UPDATE user_settings SET distance_metric = 'km' WHERE user_id = v_user_id;

    -- Trusted Contacts (Helps Trust Score: +10 points)
    INSERT INTO trusted_contacts (owner_user_id, contact_name, contact_phone_number)
    VALUES (v_user_id, 'Emergency Mom', '+1987654321');

    -- 2. Create some sample Routes
    DELETE FROM routes WHERE id IN (v_route1_id, v_route2_id, v_route3_id);

    INSERT INTO routes (id, route_number, route_name, average_fare) VALUES 
    (v_route1_id, '15', 'Mirpur to Banani', 40.00),
    (v_route2_id, '42', 'Uttara to Motijheel', 60.00),
    (v_route3_id, '8', 'Dhanmondi to Gulshan', 50.00);

    -- Route Stop
    DELETE FROM route_stops WHERE id = v_stop1_id;
    INSERT INTO route_stops (id, route_id, stop_name, latitude, longitude, sequence_order)
    VALUES (v_stop1_id, v_route1_id, 'Mirpur 10', 23.806, 90.369, 1);

    -- 3. Add Commuter Contributions (Trust Score points calculation)
    -- Route Reviews (5 reviews = 10 points)
    INSERT INTO route_reviews (route_id, user_id, rating, review_text) VALUES
    (v_route1_id, v_user_id, 4.5, 'Good ride'),
    (v_route1_id, v_user_id, 4.0, 'A bit crowded'),
    (v_route2_id, v_user_id, 5.0, 'Fast'),
    (v_route2_id, v_user_id, 3.5, 'Delay'),
    (v_route3_id, v_user_id, 4.0, 'Decent');

    -- Crowd Level Reports (3 reports = 6 points)
    INSERT INTO crowd_level_reports (route_id, stop_id, crowd_level, reported_by_user_id) VALUES
    (v_route1_id, v_stop1_id, 'high', v_user_id),
    (v_route1_id, v_stop1_id, 'moderate', v_user_id),
    (v_route2_id, NULL, 'low', v_user_id);

    -- 4. Journeys (Contributes to Total Rides, Commute Analytics, Financials)
    
    -- Journey 1: Completed, 1 day ago (adds to Ride Hours, Financials, Safe Journeys)
    INSERT INTO journeys (id, user_id, route_id, origin_latitude, origin_longitude, status, distance_km, started_at, ended_at)
    VALUES (v_journey1_id, v_user_id, v_route1_id, 23.8, 90.3, 'completed', 8.5, now() - interval '1 day' - interval '1 hour', now() - interval '1 day');
    INSERT INTO post_ride_surveys (journey_id, fare_paid) VALUES (v_journey1_id, 45.00);

    -- Journey 2: Completed, 4 days ago (custom journey -> no route_id)
    INSERT INTO journeys (id, user_id, route_id, origin_latitude, origin_longitude, status, distance_km, started_at, ended_at)
    VALUES (v_journey2_id, v_user_id, NULL, 23.7, 90.4, 'completed', 4.2, now() - interval '4 days' - interval '30 minutes', now() - interval '4 days');
    INSERT INTO post_ride_surveys (journey_id, fare_paid) VALUES (v_journey2_id, 120.00);

    -- Journey 3: Completed, 15 days ago (Current Month Financials)
    INSERT INTO journeys (id, user_id, route_id, origin_latitude, origin_longitude, status, distance_km, started_at, ended_at)
    VALUES (v_journey3_id, v_user_id, v_route2_id, 23.9, 90.4, 'completed', 15.0, now() - interval '15 days' - interval '1.5 hours', now() - interval '15 days');
    INSERT INTO post_ride_surveys (journey_id, fare_paid) VALUES (v_journey3_id, 60.00);

    -- Journey 4: Completed, 45 days ago (Previous Month Financials, for comparison metric)
    INSERT INTO journeys (id, user_id, route_id, origin_latitude, origin_longitude, status, distance_km, started_at, ended_at)
    VALUES (v_journey4_id, v_user_id, v_route2_id, 23.9, 90.4, 'completed', 15.0, now() - interval '45 days' - interval '1 hour', now() - interval '45 days');
    INSERT INTO post_ride_surveys (journey_id, fare_paid) VALUES (v_journey4_id, 65.00);

    -- Journey 5: Completed with safety alert (Unsafe Journey)
    INSERT INTO journeys (id, user_id, route_id, origin_latitude, origin_longitude, status, distance_km, started_at, ended_at)
    VALUES (v_journey5_id, v_user_id, v_route3_id, 23.7, 90.3, 'completed', 6.0, now() - interval '10 days' - interval '45 minutes', now() - interval '10 days');
    INSERT INTO post_ride_surveys (journey_id, fare_paid) VALUES (v_journey5_id, 50.00);

    -- 5. Safety Alerts and Incidents
    
    -- True alert for Journey 5 (Makes it an "unsafe" journey)
    INSERT INTO safety_alerts (user_id, journey_id, report_type, status, triggered_at)
    VALUES (v_user_id, v_journey5_id, 'sos', 'resolved', now() - interval '10 days' - interval '20 minutes');

    -- False Alarm on Journey 3 (Trust Score penalty: -15)
    INSERT INTO safety_alerts (user_id, journey_id, report_type, status, triggered_at)
    VALUES (v_user_id, v_journey3_id, 'emergency_report', 'false_alarm', now() - interval '15 days');

    -- Incident Reports (Adds to safety metrics reportsSubmitted count)
    INSERT INTO incident_reports (user_id, lighting_rating, public_visibility_rating, crowd_density_rating, security_presence_rating, harassment_frequency_rating, theft_frequency_rating, overall_safety_rating, notes)
    VALUES 
    (v_user_id, 3, 3, 3, 2, 1, 2, 2, 'Suspicious person at the bus stop'),
    (v_user_id, 4, 4, 4, 3, 1, 1, 4, 'Well lit area');

    -- 6. Journey Stops (Stops Added metric in Transit Intelligence)
    INSERT INTO journey_stops (journey_id, latitude, longitude, sequence_order)
    VALUES 
    (v_journey1_id, 23.805, 90.365, 1),
    (v_journey1_id, 23.810, 90.370, 2);

END $$;
