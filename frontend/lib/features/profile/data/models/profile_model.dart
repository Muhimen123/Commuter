import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.fullName,
    required super.email,
    required super.badgeTitle,
    required super.quickStats,
    required super.transitIntelligence,
    required super.safetyMetrics,
    required super.financialMetrics,
    required super.commuteAnalytics,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Skeleton mapping for future API/Supabase integration
    return ProfileModel(
      fullName: json['fullName'] as String? ?? 'Commuter User',
      email: json['email'] as String? ?? 'user@example.com',
      badgeTitle: json['badgeTitle'] as String? ?? 'Member',
      quickStats: const QuickStats(
        totalRides: 0,
        distanceCommuted: 0,
        distanceUnit: 'km',
        co2Saved: 0,
        co2Unit: 'kg',
      ),
      transitIntelligence: const TransitIntelligence(
        trustScorePercentage: 100,
        routesMapped: 0,
        stopsAdded: 0,
        commutersHelped: 0,
      ),
      safetyMetrics: const SafetyMetrics(
        reportsSubmitted: 0,
        safeJourneysCompleted: 0,
      ),
      financialMetrics: const FinancialMetrics(
        monthlySpend: 0.0,
        monthlyChangePercentage: 0.0,
        isSpendLowerThanLastMonth: true,
        costPerKm: 0.0,
        topRoutesAvgFare: [],
      ),
      commuteAnalytics: const CommuteAnalytics(
        spendByRoute: [],
        transitModes: [],
        rideHoursPerWeek: [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'badgeTitle': badgeTitle,
    };
  }
}
