# Ride Discovery Page Implementation Plan

Implement the "Ride Discovery" page (referenced as "Ride" in the UI) based on the provided design specification and the project's design system. This page will allow users to search for routes, filter them, and see detailed ride options with real-time-like information.

## User Review Required

> [!IMPORTANT]
> The "Planner" tab in the bottom navigation will be renamed to "Ride" to match the provided screenshot and user instructions.

## Proposed Changes

### [Core/Navigation]

#### [MODIFY] [CommuterScaffold](file:///C:/my_drive/Commuter/frontend/lib/shared/widgets/navigation_bar/commuter_scaffold.dart)
- Rename "Planner" label to "Ride" in the `NavigationBar`.

#### [MODIFY] [app.dart](file:///C:/my_drive/Commuter/frontend/lib/app.dart)
- Update imports to include the new `RideDiscoveryPage`.
- Replace `PlaceholderPage(title: 'Planner')` with `RideDiscoveryPage()`.

### [Feature: Ride Discovery]

#### [NEW] [ride_model.dart](file:///C:/my_drive/Commuter/frontend/lib/features/ride_discovery/domain/entities/ride.dart)
- Define a `Ride` entity with fields: `id`, `routeNumber`, `routeName`, `via`, `arrivalTime`, `status` (Arriving, Scheduled, Delayed), `rating`, `reviewCount`, `safetyScore`, `fare`, `isRecommended`, `alertMessage`.

#### [NEW] [ride_discovery_page.dart](file:///C:/my_drive/Commuter/frontend/lib/features/ride_discovery/presentation/pages/ride_discovery_page.dart)
- Implement the main page structure with a custom `AppBar` (matching the "Commuter" brand and profile icon), search field, filter chips, and a scrollable list of ride cards.

#### [NEW] [ride_card.dart](file:///C:/my_drive/Commuter/frontend/lib/features/ride_discovery/presentation/widgets/ride_card.dart)
- Create a specialized `RideCard` component following the Material 3 specifications:
    - `medium` corner radius (12px).
    - `level1` elevation.
    - Custom layout for route number, time, and safety metrics.
    - "Track Ride" primary action button.

#### [NEW] [search_field.dart](file:///C:/my_drive/Commuter/frontend/lib/features/ride_discovery/presentation/widgets/search_field.dart)
- Implement the rounded search bar with a prefix icon.

#### [NEW] [filter_chips.dart](file:///C:/my_drive/Commuter/frontend/lib/features/ride_discovery/presentation/widgets/filter_chips.dart)
- Implement a horizontally scrollable list of filter chips.

### [Feature: Authentication]

#### [MODIFY] [signup_page.dart](file:///C:/my_drive/Commuter/frontend/lib/features/auth/presentation/pages/signup_page.dart)
- Add a phone number field using `AuthTextField` with `keyboardType: TextInputType.phone`.

## Verification Plan

### Manual Verification
- Verify the bottom navigation label change from "Planner" to "Ride".
- Navigate to the "Ride" tab and ensure the page layout matches the screenshot.
- Check that the search bar and filter chips are rendered correctly.
- Verify that the `RideCard` components display all data points (route, time, rating, safety, fare) and adhere to the design system's spacing and tokens.
- Test responsiveness on different screen sizes (mobile focus).
