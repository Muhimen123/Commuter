# Commuter App — Design System (Material 3 / Flutter)

> **For AI agents:** This document is the source of truth for all UI generation and Flutter widget code for the Commuter app. Always pair this file with `design_tokens.json`, which contains the exact values referenced here. Never invent colors, spacing, type sizes, or corner radii — pull them from tokens. If something isn't covered here, default to Material 3 guidelines.

---

## 1. Philosophy (Material You)

- **Personalization** — theme derives from a seed color; optionally supports system Dynamic Color.
- **Adaptability** — layouts adapt to safe areas, orientation, and system font scaling.
- **Expression** — clean, high-clarity UI; avoid visual clutter, especially over the map.
- **3-Tap Rule** — every critical action (start ride, report safety issue, contact guardian) must be reachable within 3 taps from Home.

---

## 2. Theming Setup (Flutter)

```dart
ColorScheme.fromSeed(
  seedColor: const Color(0xFF307082),
  brightness: Brightness.light, // and dark variant
).copyWith(
  // override with m3_roles_light / m3_roles_dark from design_tokens.json
);
```

- Define `safety_safe`, `safety_warning`, `safety_danger` as a custom `ThemeExtension<SafetyColors>` — do **not** repurpose `error`/`primary` roles for these.
- Both light and dark themes are required. Dark mode is not optional.
- Respect system text scaling (`MediaQuery.textScaler`) up to at least 130%.

---

## 3. Layout Rules (Mobile)

| Rule | Value |
|---|---|
| Horizontal screen padding | 16px minimum (except full-bleed map screens) |
| Minimum touch target | 48x48px |
| Bottom navigation height | 80px, fixed, respects bottom safe area |
| Top app bar height | 64px |
| Content structure | Single-column, vertical stacking — no multi-column layouts |
| Map screens | Full-bleed `GoogleMap`; all UI floats above it in overlays (never push/resize the map) |
| Safe areas | All floating elements (FAB, top bar, bottom sheet) must respect notch/home-indicator insets via `SafeArea` |

---

## 4. Navigation Structure

**Bottom `NavigationBar`** — 4 fixed destinations, always visible except during Ride Flow and modal flows:
1. Map / Home
2. Route Planner
3. Safety
4. Profile

**Ride Flow** (Start → Active → End Summary) is a **modal/full-screen flow** — hide bottom nav, show a minimal top bar with back/cancel only.

**Guardian System** and **Settings** are pushed as standard routes from Profile (not tabs).

---

## 5. Component Specifications

### Buttons
| Variant | When to use | Corner radius | Height |
|---|---|---|---|
| Filled | Primary action per screen (max 1) | `full` (pill) | 40px |
| Tonal | Secondary action | `full` | 40px |
| Outlined | Tertiary / cancel actions | `full` | 40px |
| Text | Low-emphasis, inline actions | — | 40px |

States required for every button: `default`, `pressed`, `disabled` (38% opacity content), `loading` (replace label with spinner, keep width fixed).

### FAB
- Used for **one** primary action per screen only (e.g., "Start Ride" on Map, "Report" on Safety).
- Default size (56px) on primary screens; small size (40px) only within dense contexts like Active Ride overlay.
- Never place more than one FAB on screen.

### Cards
- Use `Card` (filled or outlined variant, not `elevated` with heavy shadow).
- Corner radius: `medium` (12px).
- Elevation: `level1` max — rely on tonal surface, not shadow, for depth.
- Used for: ride history items, guardian list items, safety report summaries.

### Bottom Sheets
- Corner radius: `extra_large` (28px) on top corners only.
- Elevation: `level3`.
- Used for: Safety Report Form, End Ride Summary, Guardian Invite actions, Filter/sort controls.
- Always draggable (`DraggableScrollableSheet`) if content can exceed 50% screen height.

### Text Fields
- Height: 56px, filled or outlined M3 style.
- Focus state: 2px border in `primary`.
- Error state: border + helper text in `error` role, never in `safety_danger`.
- Used in: Sign Up, Log In, Route Planner input, Add Guardian search.

### Lists / Switches
- Guardian list and Settings use standard M3 `ListTile` with `Switch.adaptive` for toggles.
- Swipe-to-reveal actions (e.g., revoke guardian) use standard M3 dismissible patterns with a confirmation step — never destructive-on-swipe without confirm.

### Map Overlays
- All floating overlay surfaces (top bar, bottom sheet, FAB) use `SurfaceTint` semi-transparent containers — never fully opaque cards that obscure map context unnecessarily.
- Safety heatmap toggle lives in the map's top app bar as an `IconButton` or `SegmentedButton`.

---

## 6. Page-Specific Guidance

| Page | Key Components |
|---|---|
| Splash / Landing | Full-bleed brand background, single Filled button ("Get Started") |
| Sign Up / Log In | TextFields, OAuth buttons (Outlined), Filled primary CTA |
| Forgot Password | Single TextField + Filled button, minimal top bar with back |
| Map / Home | Full-bleed map, floating top bar, FAB (Start Ride), heatmap toggle |
| Route Planner | Two TextFields (A/B), suggested route Cards, Filled CTA |
| Safety | Map/list toggle, FAB (Report), Card list of nearby reports |
| Profile | ListTile navigation to Edit Profile / Settings / History / Guardians |
| Start Ride | Route confirmation Card, Filled CTA "Start" |
| Active Ride | Full-bleed map, minimal overlay controls, one-touch stop button, guardian-sharing indicator |
| End Ride Summary | Bottom sheet: fare input, star rating, feedback TextField |
| Safety Report Form | Bottom sheet: lighting/foot-traffic selectors (SegmentedButton), notes TextField, map pin |
| Guardians List | ListTiles with status (active/pending), swipe-to-revoke with confirm |
| Add Guardian | Search TextField, results list, invite button per row |
| Guardian Invite | Card with accept (Filled) / decline (Outlined) actions |
| Monitoring Screen | Full-bleed map showing commuter's live position, minimal top bar |
| Edit Profile | Avatar picker, TextFields, Filled save button |
| App Settings | ListTiles with Switches (notifications, GPS/battery) |
| Ride History | Card list, tap-through to Ride Detail |
| Ride Detail | Static summary layout: map snapshot, fare, rating, notes |

---

## 7. Do / Don't

✅ One Filled button per screen — everything else is Tonal/Outlined/Text
✅ Map is always full-bleed; UI floats above it
✅ Safety colors (`safe`/`warning`/`danger`) only for safety-domain content, never generic UI states
✅ 48px minimum touch targets everywhere, including list row actions
✅ Bottom sheets for any form/input triggered from a map or list context

🚫 Never use more than one FAB per screen
🚫 Never hardcode hex colors or px values — always reference tokens/theme roles
🚫 Never use heavy drop shadows for elevation — use M3 tonal surfaces
🚫 Never shrink text below `labelSmall` (11px)
🚫 Never break the bottom navigation bar during core tab screens (only hide it in Ride Flow / modals)

---

## 8. Accessibility Minimums

- Contrast: 4.5:1 body text, 3:1 large text/icons
- Touch targets: 48x48px minimum
- Dark mode: required, full parity with light mode
- Dynamic text scaling: support up to 130%
- All interactive elements have semantic labels for screen readers (`Semantics` widget in Flutter)

---

## 9. Reference Priority for Agents

When a scenario isn't explicitly covered above:
1. Check `design_tokens.json` for the closest matching value.
2. Default to official **Material 3** guidelines (m3.material.io).
3. Default to platform convention (Android primary, since this targets Material 3) unless building iOS-specific adaptive behavior.
