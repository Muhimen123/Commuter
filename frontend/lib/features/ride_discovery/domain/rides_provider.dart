import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/supabase_ride_repository.dart';
import 'entities/ride.dart';

final ridesProvider = FutureProvider<List<Ride>>((ref) {
  final repository = ref.watch(rideRepositoryProvider);
  return repository.getRides();
});
