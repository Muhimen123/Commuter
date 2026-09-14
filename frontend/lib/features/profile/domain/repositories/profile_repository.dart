import '../entities/profile_entity.dart';
import '../entities/ride_history_entry.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfileData();
  Future<List<RideHistoryEntry>> getRideHistory();
}
