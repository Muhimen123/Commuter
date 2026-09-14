import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/supabase_profile_repository.dart';
import 'repositories/profile_repository.dart';
import 'entities/profile_entity.dart';
import 'entities/ride_history_entry.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepositoryImpl(Supabase.instance.client);
});

final profileProvider = FutureProvider.autoDispose<ProfileEntity>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfileData();
});

final rideHistoryProvider = FutureProvider.autoDispose<List<RideHistoryEntry>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getRideHistory();
});
