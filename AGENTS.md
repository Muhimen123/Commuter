# Commuter App — Agent Instructions

## Project Layout

Monorepo with three top-level directories:

- **`frontend/`** — Flutter app (the only active codebase)
- **`backend/`** — empty placeholder
- **`supabase/`** — empty placeholder

**All `flutter` commands must run from `frontend/`.**

## Architecture: Feature-First (vertical slices)

```
frontend/lib/
├── main.dart
├── app.dart                # GoRouter setup, MaterialApp.router, routes
├── core/theme/             # AppColors, AppTheme, design tokens Dart classes
├── shared/widgets/         # Cross-cutting widgets (e.g., CommuterScaffold)
└── features/
    └── [feature_name]/
        ├── data/           # Repositories, API clients, data models
        ├── domain/         # Entities, use cases
        └── presentation/
            ├── pages/      # Full-screen routes
            └── widgets/    # Feature-local reusable widgets
```

Existing features: `auth`, `map`, `onboarding`, `profile`, `ride_discovery`, `safety`.

**Rules:**
- Never add feature files outside `features/[name]/`. Only app-wide config (`app.dart`, `main.dart`, `core/`, `shared/`) lives at the `lib/` root.
- Presentation layer must stay UI-only; move business logic to `domain/` or `data/`.
- A feature is a full vertical slice — do not create a feature with only a `presentation/` folder.

## Tech Stack (verified from `pubspec.yaml`)

| Concern | Package |
|---|---|
| Routing | `go_router` — `StatefulShellRoute.indexedStack` in `app.dart` |
| Map | `flutter_map` + OpenStreetMap tiles (NOT Google Maps) |
| Location | `geolocator`, `flutter_map_location_marker` |
| Font | `google_fonts` (Inter) |
| Animation | `flutter_animate` |
| Lat/Lng | `latlong2` |

**IMPORTANT:** `SOUL.md` and `DESIGN_SYSTEM.md` reference "Google Maps Platform" — this is outdated. The actual map implementation uses `flutter_map` with OpenStreetMap tile URLs. When writing map code, use `flutter_map` / `latlong2`, not `google_maps_flutter`.

## Design System

Three files you must consult before any UI work:

1. **`SOUL.md`** — product philosophy and feature requirements
2. **`DESIGN_SYSTEM.md`** — Material 3 component specs, layout rules, do/don't
3. **`DESIGN_TOKENS.json`** — canonical color, spacing, typography, radius, and elevation values

**Known inconsistency:** There are two Dart `AppColors` classes — one in `core/theme/app_colors.dart` and one in `core/theme/design_tokens.dart`. When adding colors, prefer the canonical values in `DESIGN_TOKENS.json` and note this duplication if it affects your work.

## Theme Setup (`core/theme/app_theme.dart`)

- `AppTheme.lightTheme` and `AppTheme.darkTheme` are the two theme objects
- Safety colors (`safe`/`warning`/`danger`) live in a custom `ThemeExtension<SafetyColors>` — never repurpose `error`/`primary` for safety states
- Dark mode is required; `ThemeMode.light` is currently hardcoded in `app.dart` (set `ThemeMode.system` when dark mode is ready)

## Commands

```bash
# From frontend/
flutter pub get          # install deps
flutter analyze          # static analysis (uses flutter_lints)
flutter test             # run tests (currently none exist)
flutter run              # launch on connected device/emulator
```

No codegen, no `build_runner`, no `.g.dart` files in use.

## Gotchas

- **No tests exist yet** — `frontend/test/` is empty
- **No assets directory** — no images, icons, or fonts bundled
- **No `.env` files** — no environment config loaded at runtime
- **No backend/supabase code** — those directories contain only `.gitkeep`
- **Dart SDK:** `^3.12.2` (check compatibility when adding packages)
- **Bottom nav height is 70px** in `CommuterScaffold`, though `DESIGN_TOKENS.json` says 80px — align these when touching navigation
