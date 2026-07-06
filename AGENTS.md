# Project Context: Commuter App

This is a Flutter public transit application based on a feature-first architecture.

## Project Structure
All new features and code must follow this structure:

```text
lib/
├── app.dart              # Main application entry and routing
├── core/                 # App-wide infrastructure (API, utils, theme)
├── shared/               # Reusable widgets and services
└── features/             # Feature-specific modules
    ├── [feature_name]/   # e.g., transit, safety, security
    │   ├── data/         # Repositories, models
    │   ├── domain/       # Use cases, business logic
    │   └── presentation/ # Widgets, screens, state management
```

## Architecture Rules
- Follow the Feature-First approach. Do not add files to top-level `lib/` unless it is an app-wide configuration or entry point.
- Keep `presentation` widgets clean; move logic to `domain` or `data` layers.
- When creating a new feature, always use the `features/[feature_name]/[layer]/` structure.

## Technical Constraints
- Framework: Flutter
- Mapping: Google Maps Platform
