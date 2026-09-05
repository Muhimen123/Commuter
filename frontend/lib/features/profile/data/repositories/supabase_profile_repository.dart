import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class SupabaseProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _client;

  SupabaseProfileRepositoryImpl(this._client);

  @override
  Future<ProfileEntity> getProfileData() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    
    final userId = user.id;

    // Default values
    String fullName = 'Unknown User';
    String email = user.email ?? '';
    String? profilePhotoUrl;
    String badgeTitle = 'Novice';

    // Fetch user details
    final userData = await _client
        .from('users')
        .select('full_name, email, profile_photo_url')
        .eq('id', userId)
        .maybeSingle();
        
    if (userData != null) {
      fullName = userData['full_name'] as String? ?? fullName;
      email = userData['email'] as String? ?? email;
      profilePhotoUrl = userData['profile_photo_url'] as String?;
    }

    // Fetch user settings
    final settingsData = await _client
        .from('user_settings')
        .select('distance_metric')
        .eq('user_id', userId)
        .maybeSingle();
    final String distanceUnit = settingsData?['distance_metric'] as String? ?? 'km';

    // Fetch journeys
    final journeysResponse = await _client
        .from('journeys')
        .select('id, distance_km, status, route_id, started_at, ended_at, routes(route_name), post_ride_surveys(fare_paid)')
        .eq('user_id', userId);

    int totalRides = 0;
    double distanceCommuted = 0.0;
    Set<String> mappedRoutes = {};
    
    List<Map<String, dynamic>> completedJourneysLast30Days = [];
    List<Map<String, dynamic>> completedJourneysPrev30Days = [];
    List<Map<String, dynamic>> completedJourneysLast7Days = [];
    
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    for (final j in journeysResponse) {
      if (j['status'] == 'completed') {
        totalRides++;
        distanceCommuted += (j['distance_km'] as num?)?.toDouble() ?? 0.0;
        
        final routeId = j['route_id'] as String?;
        if (routeId != null) {
          mappedRoutes.add(routeId);
        }
        
        final startedAtStr = j['started_at'] as String?;
        if (startedAtStr != null) {
          final startedAt = DateTime.tryParse(startedAtStr);
          if (startedAt != null) {
            if (startedAt.isAfter(thirtyDaysAgo)) {
              completedJourneysLast30Days.add(j);
            } else if (startedAt.isAfter(sixtyDaysAgo) && startedAt.isBefore(thirtyDaysAgo)) {
              completedJourneysPrev30Days.add(j);
            }
            
            if (startedAt.isAfter(sevenDaysAgo)) {
              completedJourneysLast7Days.add(j);
            }
          }
        }
      }
    }

    // CO2 Saved (0.15 kg per km)
    double co2Saved = distanceCommuted * 0.15;
    
    // Badge Title
    if (totalRides > 50) {
      badgeTitle = 'Transit Pioneer';
    } else if (totalRides >= 10) {
      badgeTitle = 'Regular Commuter';
    }

    // Fetch journey stops
    int stopsAdded = 0;
    if (totalRides > 0) {
      final journeyIds = journeysResponse.map((e) => e['id']).toList();
      if (journeyIds.isNotEmpty) {
        try {
          final stopsCountResponse = await _client
              .from('journey_stops')
              .select('id')
              .inFilter('journey_id', journeyIds);
          stopsAdded = stopsCountResponse.length;
        } catch (e) {
          // ignore
        }
      }
    }

    // Commuters Helped (crowd reports + route reviews)
    int commutersHelped = 0;
    try {
      final crowdReports = await _client.from('crowd_level_reports').select('id').eq('reported_by_user_id', userId);
      final routeReviews = await _client.from('route_reviews').select('id').eq('user_id', userId);
      commutersHelped = crowdReports.length + routeReviews.length;
    } catch (_) {}

    // Safety Metrics
    int reportsSubmitted = 0;
    try {
      final incidentReports = await _client.from('incident_reports').select('id').eq('user_id', userId);
      reportsSubmitted = incidentReports.length;
    } catch (_) {}

    int safeJourneysCompleted = totalRides;
    try {
      // Find journeys with safety alerts
      final safetyAlerts = await _client.from('safety_alerts').select('journey_id').eq('user_id', userId).not('journey_id', 'is', null);
      final unsafeJourneyIds = safetyAlerts.map((e) => e['journey_id'] as String).toSet();
      safeJourneysCompleted = journeysResponse.where((j) => j['status'] == 'completed' && !unsafeJourneyIds.contains(j['id'])).length;
    } catch (_) {}

    int trustScorePercentage = 50; // Base score
    
    // +2 for every contribution (max +30)
    int contributionPoints = commutersHelped * 2;
    if (contributionPoints > 30) contributionPoints = 30;
    trustScorePercentage += contributionPoints;
    
    // +1 for every 5 rides (max +10)
    int ridePoints = totalRides ~/ 5;
    if (ridePoints > 10) ridePoints = 10;
    trustScorePercentage += ridePoints;
    
    // +10 if has trusted contacts
    try {
      final trustedContactsResponse = await _client.from('trusted_contacts').select('id').eq('owner_user_id', userId).limit(1);
      if (trustedContactsResponse.isNotEmpty) {
        trustScorePercentage += 10;
      }
    } catch (_) {}
    
    // -15 for every false alarm
    try {
      final falseAlarmsResponse = await _client.from('safety_alerts').select('id').eq('user_id', userId).eq('status', 'false_alarm');
      int falseAlarmsCount = falseAlarmsResponse.length;
      trustScorePercentage -= (falseAlarmsCount * 15);
    } catch (_) {}
    
    if (trustScorePercentage > 100) trustScorePercentage = 100;
    if (trustScorePercentage < 0) trustScorePercentage = 0;

    // Financial Metrics
    double monthlySpend = 0.0;
    double prevMonthlySpend = 0.0;
    double distanceLast30Days = 0.0;

    Map<String, List<double>> routeFares = {};
    Map<String, double> routeTotalSpend = {};

    for (final j in completedJourneysLast30Days) {
      final distance = (j['distance_km'] as num?)?.toDouble() ?? 0.0;
      distanceLast30Days += distance;
      
      final surveys = j['post_ride_surveys'];
      double fare = 0.0;
      if (surveys != null) {
         if (surveys is List && surveys.isNotEmpty) {
           fare = (surveys[0]['fare_paid'] as num?)?.toDouble() ?? 0.0;
         } else if (surveys is Map) {
           fare = (surveys['fare_paid'] as num?)?.toDouble() ?? 0.0;
         }
      }
      monthlySpend += fare;
      
      final route = j['routes'];
      String routeName = 'Unknown Route';
      if (route != null) {
        if (route is List && route.isNotEmpty) {
          routeName = route[0]['route_name'] as String? ?? 'Unknown Route';
        } else if (route is Map) {
          routeName = route['route_name'] as String? ?? 'Unknown Route';
        }
      }
      
      routeFares.putIfAbsent(routeName, () => []).add(fare);
      routeTotalSpend[routeName] = (routeTotalSpend[routeName] ?? 0.0) + fare;
    }

    for (final j in completedJourneysPrev30Days) {
      final surveys = j['post_ride_surveys'];
      double fare = 0.0;
      if (surveys != null) {
         if (surveys is List && surveys.isNotEmpty) {
           fare = (surveys[0]['fare_paid'] as num?)?.toDouble() ?? 0.0;
         } else if (surveys is Map) {
           fare = (surveys['fare_paid'] as num?)?.toDouble() ?? 0.0;
         }
      }
      prevMonthlySpend += fare;
    }

    double monthlyChangePercentage = 0.0;
    if (prevMonthlySpend > 0) {
      monthlyChangePercentage = ((monthlySpend - prevMonthlySpend) / prevMonthlySpend) * 100;
    } else if (monthlySpend > 0) {
      monthlyChangePercentage = 100.0;
    }

    bool isSpendLowerThanLastMonth = monthlySpend < prevMonthlySpend;
    double costPerKm = distanceLast30Days > 0 ? (monthlySpend / distanceLast30Days) : 0.0;

    List<RouteFare> topRoutesAvgFare = [];
    routeFares.forEach((routeName, fares) {
      final avg = fares.reduce((a, b) => a + b) / fares.length;
      topRoutesAvgFare.add(RouteFare(routeName: routeName, fare: avg));
    });
    topRoutesAvgFare.sort((a, b) => b.fare.compareTo(a.fare));
    if (topRoutesAvgFare.length > 3) {
      topRoutesAvgFare = topRoutesAvgFare.sublist(0, 3);
    }

    // Commute Analytics
    List<RouteSpend> spendByRoute = [];
    routeTotalSpend.forEach((routeName, total) {
      spendByRoute.add(RouteSpend(routeName: routeName, totalSpend: total));
    });
    spendByRoute.sort((a, b) => b.totalSpend.compareTo(a.totalSpend));
    if (spendByRoute.length > 5) {
      spendByRoute = spendByRoute.sublist(0, 5);
    }

    int busCount = 0;
    int customCount = 0;
    for (final j in journeysResponse) {
      if (j['route_id'] != null) {
        busCount++;
      } else {
        customCount++;
      }
    }
    
    int totalTransit = busCount + customCount;
    List<TransitModeShare> transitModes = [];
    if (totalTransit > 0) {
      if (busCount > 0) transitModes.add(TransitModeShare(modeName: 'Bus', percentage: (busCount / totalTransit * 100).round()));
      if (customCount > 0) transitModes.add(TransitModeShare(modeName: 'Custom', percentage: (customCount / totalTransit * 100).round()));
    }

    Map<String, double> dayHours = {
      'M': 0.0, 'T': 0.0, 'W': 0.0, 'Th': 0.0, 'F': 0.0, 'S': 0.0, 'Su': 0.0
    };
    
    for (final j in completedJourneysLast7Days) {
      final startedStr = j['started_at'] as String?;
      final endedStr = j['ended_at'] as String?;
      if (startedStr != null && endedStr != null) {
        final start = DateTime.tryParse(startedStr);
        final end = DateTime.tryParse(endedStr);
        if (start != null && end != null) {
          final diff = end.difference(start).inMinutes / 60.0;
          String dayLabel = 'M';
          switch (start.weekday) {
            case 1: dayLabel = 'M'; break;
            case 2: dayLabel = 'T'; break;
            case 3: dayLabel = 'W'; break;
            case 4: dayLabel = 'Th'; break;
            case 5: dayLabel = 'F'; break;
            case 6: dayLabel = 'S'; break;
            case 7: dayLabel = 'Su'; break;
          }
          dayHours[dayLabel] = (dayHours[dayLabel] ?? 0) + diff;
        }
      }
    }

    List<DailyRideHours> rideHoursPerWeek = dayHours.entries.map((e) => DailyRideHours(dayLabel: e.key, hours: e.value)).toList();

    return ProfileEntity(
      fullName: fullName,
      email: email,
      profilePhotoUrl: profilePhotoUrl,
      badgeTitle: badgeTitle,
      quickStats: QuickStats(
        totalRides: totalRides,
        distanceCommuted: distanceCommuted,
        distanceUnit: distanceUnit,
        co2Saved: co2Saved,
        co2Unit: 'kg',
      ),
      transitIntelligence: TransitIntelligence(
        trustScorePercentage: trustScorePercentage,
        routesMapped: mappedRoutes.length,
        stopsAdded: stopsAdded,
        commutersHelped: commutersHelped,
      ),
      safetyMetrics: SafetyMetrics(
        reportsSubmitted: reportsSubmitted,
        safeJourneysCompleted: safeJourneysCompleted,
      ),
      financialMetrics: FinancialMetrics(
        monthlySpend: monthlySpend,
        monthlyChangePercentage: monthlyChangePercentage,
        isSpendLowerThanLastMonth: isSpendLowerThanLastMonth,
        costPerKm: costPerKm,
        topRoutesAvgFare: topRoutesAvgFare,
      ),
      commuteAnalytics: CommuteAnalytics(
        spendByRoute: spendByRoute,
        transitModes: transitModes,
        rideHoursPerWeek: rideHoursPerWeek,
      ),
    );
  }
}
