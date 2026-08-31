import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether ride simulation mode is active. When on, the active journey's
/// location pings are driven by a [RideSimulator] walking the drafted route
/// instead of real device GPS. Toggled via a long-press on the Home nav tab.
///
/// Intentionally in-memory only (not persisted) — it resets to off on app
/// restart so a simulated session can never be left on by accident.
final simulationEnabledProvider = StateProvider<bool>((ref) => false);
