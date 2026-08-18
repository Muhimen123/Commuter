/// Shared API configuration for Google Maps services.
///
/// The API key is injected at build time via `--dart-define-from-file=.env`.
/// Set `GOOGLE_MAPS_API_KEY=your_key` in `.env` (gitignored) and run:
///   flutter run --dart-define-from-file=.env
///
/// See `.env.template` for the required format.
const String googleMapsApiKey = String.fromEnvironment(
  'GOOGLE_MAPS_API_KEY',
  defaultValue: '',
);