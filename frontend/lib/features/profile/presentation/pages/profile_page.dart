import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/domain/auth_notifier.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/dummy_profile_repository.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/profile_nav_card.dart';
import '../widgets/transit_intelligence_section.dart';
import '../widgets/safety_metrics_section.dart';
import '../widgets/financial_spending_section.dart';
import '../widgets/commute_analytics_section.dart';
import '../widgets/logout_card.dart';
import '../widgets/edit_profile_dialog.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final ProfileRepository _repository = DummyProfileRepositoryImpl();
  late Future<ProfileEntity> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _repository.getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: FutureBuilder<ProfileEntity>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Unable to load profile'));
            }

            final baseProfile = snapshot.data!;
            final profile = authUser != null
                ? ProfileEntity(
                    fullName: authUser.fullName.isNotEmpty
                        ? authUser.fullName
                        : baseProfile.fullName,
                    email: authUser.email.isNotEmpty
                        ? authUser.email
                        : baseProfile.email,
                    badgeTitle: baseProfile.badgeTitle,
                    quickStats: baseProfile.quickStats,
                    transitIntelligence: baseProfile.transitIntelligence,
                    safetyMetrics: baseProfile.safetyMetrics,
                    financialMetrics: baseProfile.financialMetrics,
                    commuteAnalytics: baseProfile.commuteAnalytics,
                  )
                : baseProfile;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileHeaderCard(
                    profile: profile,
                    onEditProfile: () => _showEditProfile(context),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  QuickStatsRow(stats: profile.quickStats),
                  const SizedBox(height: AppSpacing.lg),
                  ProfileNavCard(
                    icon: Icons.history,
                    title: 'Ride History',
                    onTap: () => _showRideHistory(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ProfileNavCard(
                    icon: Icons.people_outline,
                    title: 'Manage Trusted Guardians',
                    onTap: () => _showTrustedContacts(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ProfileNavCard(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => _showSettings(context),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TransitIntelligenceSection(
                      intelligence: profile.transitIntelligence),
                  const SizedBox(height: AppSpacing.lg),
                  SafetyMetricsSection(metrics: profile.safetyMetrics),
                  const SizedBox(height: AppSpacing.lg),
                  FinancialSpendingSection(metrics: profile.financialMetrics),
                  const SizedBox(height: AppSpacing.lg),
                  CommuteAnalyticsSection(analytics: profile.commuteAnalytics),
                  const SizedBox(height: AppSpacing.lg),
                  LogoutCard(
                    onLogout: () async {
                      await ref.read(authProvider.notifier).signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showRideHistory(BuildContext context) {
    context.push('/ride_history');
  }

  void _showTrustedContacts(BuildContext context) {
    context.push('/trusted_contacts');
  }

  void _showEditProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EditProfileDialog(),
    );
  }

  void _showSettings(BuildContext context) {
    context.push('/settings');
  }
}
