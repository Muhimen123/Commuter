# Profile Stats Calculation Formulas

This document outlines how the commuter profile statistics are calculated from the Supabase tables.

## Quick Stats
- **Total Rides (`totalRides`)**: 
  - Formula: Count of all `journeys` where `status = 'completed'` for the user.
- **Distance Commuted (`distanceCommuted`)**: 
  - Formula: Sum of `distance_km` from all `completed` journeys for the user.
- **CO2 Saved (`co2Saved`)**: 
  - Formula: `distanceCommuted * 0.15` (kg). Assumes average emission savings of 150g CO2 per km traveled via public transit over a personal vehicle.
- **Badge Title (`badgeTitle`)**: 
  - Formula: Derived from `totalRides`. `< 10` = 'Novice', `10 - 50` = 'Regular Commuter', `> 50` = 'Transit Pioneer'.

## Transit Intelligence
- **Community Trust Score (`trustScorePercentage`)**: 
  - Formula: Based on a weighted contribution model:
    - Base score: 50%
    - +2% for every `route_review` or `crowd_level_report` (max +30%)
    - +1% for every 5 completed rides (max +10%)
    - +10% if the user has at least 1 `trusted_contacts` set up
    - -15% for every `safety_alerts` triggered by the user that is marked as `false_alarm`
- **Routes Mapped (`routesMapped`)**: 
  - Formula: Count of distinct `route_id`s from all `completed` journeys.
- **Stops Added (`stopsAdded`)**: 
  - Formula: Count of all `journey_stops` linked to any of the user's journeys.
- **Commuters Helped (`commutersHelped`)**: 
  - Formula: The sum of the count of `crowd_level_reports` and `route_reviews` created by the user.

## Safety Metrics
- **Reports Submitted (`reportsSubmitted`)**: 
  - Formula: Count of all `incident_reports` where `user_id` matches the user.
- **Safe Journeys Completed (`safeJourneysCompleted`)**: 
  - Formula: `totalRides - (count of completed journeys that have an associated safety_alert triggered by the user)`.

## Financial Metrics (Rolling 30 Days)
- **Monthly Spend (`monthlySpend`)**: 
  - Formula: Sum of `fare_paid` from `post_ride_surveys` for journeys completed in the last 30 days.
- **Monthly Change Percentage (`monthlyChangePercentage`)**: 
  - Formula: `((monthlySpend - previousMonthSpend) / max(1, previousMonthSpend)) * 100`. Compares the last 30 days against the 30-day period prior to that.
- **Spend Lower Than Last Month (`isSpendLowerThanLastMonth`)**: 
  - Formula: Boolean, `monthlySpend < previousMonthSpend`.
- **Cost Per Km (`costPerKm`)**: 
  - Formula: `monthlySpend / distanceCommuted in the last 30 days`.
- **Top Routes Avg Fare (`topRoutesAvgFare`)**: 
  - Formula: `fare_paid` grouped by `route_name`, averaged, and sorted descending by fare to return the top 3 most expensive routes.

## Commute Analytics
- **Spend by Route (`spendByRoute`)**: 
  - Formula: Sum of `fare_paid` grouped by `route_name` across all time, returning the top 5 highest-spend routes.
- **Transit Mode Share (`transitModes`)**: 
  - Formula: Percentage based on `route_id`. If `route_id` is NOT NULL, it is classified as 'Bus'. If `route_id` IS NULL, it is classified as 'Custom/Walk'.
- **Ride Hours Per Week (`rideHoursPerWeek`)**: 
  - Formula: For the last 7 days, sum of the duration `(ended_at - started_at)` grouped by day of the week (M, T, W, Th, F, S, Su).
