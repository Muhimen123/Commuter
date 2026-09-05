import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class DummyProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<ProfileEntity> getProfileData() async {
    // Simulate slight latency or immediate return of mock data matching reference design
    return const ProfileEntity(
      fullName: 'Jane Doe',
      email: 'jane@example.com',
      profilePhotoUrl: null,
      badgeTitle: 'Transit Pioneer',
      quickStats: QuickStats(
        totalRides: 342,
        distanceCommuted: 1250,
        distanceUnit: 'mi',
        co2Saved: 450,
        co2Unit: 'kg',
      ),
      transitIntelligence: TransitIntelligence(
        trustScorePercentage: 98,
        routesMapped: 12,
        stopsAdded: 5,
        commutersHelped: 1402,
      ),
      safetyMetrics: SafetyMetrics(
        reportsSubmitted: 3,
        safeJourneysCompleted: 339,
      ),
      financialMetrics: FinancialMetrics(
        monthlySpend: 142.50,
        monthlyChangePercentage: 5.0,
        isSpendLowerThanLastMonth: true,
        costPerKm: 0.11,
        topRoutesAvgFare: [
          RouteFare(routeName: 'Rt 42', fare: 2.50),
          RouteFare(routeName: 'Rt 15', fare: 1.75),
          RouteFare(routeName: 'Rt 8', fare: 3.00),
        ],
      ),
      commuteAnalytics: CommuteAnalytics(
        spendByRoute: [
          RouteSpend(routeName: 'Rt 42', totalSpend: 45.0),
          RouteSpend(routeName: 'Rt 15', totalSpend: 32.0),
          RouteSpend(routeName: 'Rt 8', totalSpend: 24.0),
          RouteSpend(routeName: 'Rt 22', totalSpend: 16.0),
          RouteSpend(routeName: 'Rt 9', totalSpend: 10.0),
        ],
        transitModes: [
          TransitModeShare(modeName: 'Bus', percentage: 65),
          TransitModeShare(modeName: 'Rickshaw', percentage: 20),
          TransitModeShare(modeName: 'Laguna', percentage: 15),
        ],
        rideHoursPerWeek: [
          DailyRideHours(dayLabel: 'M', hours: 1.2),
          DailyRideHours(dayLabel: 'T', hours: 4.2),
          DailyRideHours(dayLabel: 'W', hours: 6.0),
          DailyRideHours(dayLabel: 'T', hours: 3.2),
          DailyRideHours(dayLabel: 'F', hours: 4.8),
          DailyRideHours(dayLabel: 'S', hours: 0.8),
          DailyRideHours(dayLabel: 'S', hours: 0.8),
        ],
      ),
    );
  }
}
