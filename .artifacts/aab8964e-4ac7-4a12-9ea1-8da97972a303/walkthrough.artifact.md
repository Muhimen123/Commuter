# Ride Discovery and Signup Page Walkthrough

I have implemented the new Ride Discovery feature and updated the Signup page as requested.

## Changes Overview

### 1. Ride Discovery Feature
A new feature module has been created to handle ride discovery, allowing users to find and track bus routes.

- **New Page**: [RideDiscoveryPage](file:///C:/my_drive/Commuter/frontend/lib/features/ride_discovery/presentation/pages/ride_discovery_page.dart) serves as the main entry point for finding rides.
- **Custom Components**:
    - [RideCard](file:///C:/my_drive/Commuter/frontend/lib/features/ride_discovery/presentation/widgets/ride_card.dart): A detailed Material 3 card displaying route info, arrival status (Arriving, Scheduled, Delayed), safety scores, and ratings.
    - [RideSearchField](file:///C:/my_drive/Commuter/frontend/lib/features/ride_discovery/presentation/widgets/search_field.dart): A modern, rounded search bar.
    - [RideFilterChips](file:///C:/my_drive/Commuter/frontend/lib/features/ride_discovery/presentation/widgets/filter_chips.dart): Horizontal filters for "Nearby", "Safest", etc.
- **Data Model**: A new [Ride](file:///C:/my_drive/Commuter/frontend/lib/features/ride_discovery/domain/entities/ride.dart) entity to represent transit options.

### 2. Navigation Update
- The "Planner" tab in the bottom navigation has been renamed to **"Ride"** in [CommuterScaffold](file:///C:/my_drive/Commuter/frontend/lib/shared/widgets/navigation_bar/commuter_scaffold.dart).
- The route for the second tab in [app.dart](file:///C:/my_drive/Commuter/frontend/lib/app.dart) now correctly points to the `RideDiscoveryPage`.

### 3. Authentication Update
- Added a **Phone Number** field to the [SignupPage](file:///C:/my_drive/Commuter/frontend/lib/features/auth/presentation/pages/signup_page.dart) using the `TextInputType.phone` for an optimized keyboard experience.

### 4. UI Fixes
- **Responsive Layout**: Fixed a pixel overflow issue in the `RideCard`. Instead of truncating text, I implemented a `Wrap` layout that allows the Safety Score and Ratings to stack vertically on narrow devices. This ensures all information remains visible while naturally increasing the card's height as needed.
- **Badge Wrapping**: Updated the "Recommended" badge to support multi-line text, ensuring long labels don't cause layout breaks.
- **Search Bar Refinement**: Updated the search bar's background color to `surfaceContainerHigh` and replaced the shadow with a subtle border. This allows it to blend more naturally with the beige background while maintaining its distinct identity as an interactive element.
- **AppBar Cleanup**: Removed the profile button from the top right of the `RideDiscoveryPage` to simplify the interface.

> [!NOTE]
> The UI adheres strictly to the `DESIGN_TOKENS.json` and Material 3 principles (pill buttons, tonal surfaces, medium corner radii).

### Automated Checks
- `analyze_file` was run on `RideDiscoveryPage` and `SignupPage` with no errors found.

### Manual Verification Steps (Recommended)
1. Launch the app and navigate to the **Ride** tab.
2. Verify that the search bar, filter chips, and ride cards match the design spec.
3. Check the **Signup** page (from the Login screen) to confirm the new Phone Number field is present between Email and Password.

render_diffs(file:///C:/my_drive/Commuter/frontend/lib/features/auth/presentation/pages/signup_page.dart)
render_diffs(file:///C:/my_drive/Commuter/frontend/lib/shared/widgets/navigation_bar/commuter_scaffold.dart)
render_diffs(file:///C:/my_drive/Commuter/frontend/lib/app.dart)
