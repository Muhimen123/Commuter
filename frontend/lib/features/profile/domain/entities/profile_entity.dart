class ProfileEntity {
  final String fullName;
  final String email;
  final String? profilePhotoUrl;
  final String badgeTitle;
  final QuickStats quickStats;
  final TransitIntelligence transitIntelligence;
  final SafetyMetrics safetyMetrics;
  final FinancialMetrics financialMetrics;
  final CommuteAnalytics commuteAnalytics;

  const ProfileEntity({
    required this.fullName,
    required this.email,
    this.profilePhotoUrl,
    required this.badgeTitle,
    required this.quickStats,
    required this.transitIntelligence,
    required this.safetyMetrics,
    required this.financialMetrics,
    required this.commuteAnalytics,
  });
}

class QuickStats {
  final int totalRides;
  final double distanceCommuted;
  final String distanceUnit;
  final double co2Saved;
  final String co2Unit;

  const QuickStats({
    required this.totalRides,
    required this.distanceCommuted,
    required this.distanceUnit,
    required this.co2Saved,
    required this.co2Unit,
  });
}

class TransitIntelligence {
  final int trustScorePercentage;
  final int routesMapped;
  final int stopsAdded;
  final int commutersHelped;

  const TransitIntelligence({
    required this.trustScorePercentage,
    required this.routesMapped,
    required this.stopsAdded,
    required this.commutersHelped,
  });
}

class SafetyMetrics {
  final int reportsSubmitted;
  final int safeJourneysCompleted;

  const SafetyMetrics({
    required this.reportsSubmitted,
    required this.safeJourneysCompleted,
  });
}

class FinancialMetrics {
  final double monthlySpend;
  final double monthlyChangePercentage;
  final bool isSpendLowerThanLastMonth;
  final double costPerKm;
  final List<RouteFare> topRoutesAvgFare;

  const FinancialMetrics({
    required this.monthlySpend,
    required this.monthlyChangePercentage,
    required this.isSpendLowerThanLastMonth,
    required this.costPerKm,
    required this.topRoutesAvgFare,
  });
}

class RouteFare {
  final String routeName;
  final double fare;

  const RouteFare({
    required this.routeName,
    required this.fare,
  });
}

class CommuteAnalytics {
  final List<RouteSpend> spendByRoute;
  final List<TransitModeShare> transitModes;
  final List<DailyRideHours> rideHoursPerWeek;

  const CommuteAnalytics({
    required this.spendByRoute,
    required this.transitModes,
    required this.rideHoursPerWeek,
  });
}

class RouteSpend {
  final String routeName;
  final double totalSpend;

  const RouteSpend({
    required this.routeName,
    required this.totalSpend,
  });
}

class TransitModeShare {
  final String modeName;
  final int percentage;

  const TransitModeShare({
    required this.modeName,
    required this.percentage,
  });
}

class DailyRideHours {
  final String dayLabel;
  final double hours;

  const DailyRideHours({
    required this.dayLabel,
    required this.hours,
  });
}
