import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/animated_branch_container.dart';
import 'package:frontend/core/navigation/page_transitions.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/map/presentation/pages/map_page.dart';

import 'package:frontend/features/onboarding/presentation/pages/splash_page.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/signup_page.dart';
import 'package:frontend/features/auth/presentation/pages/check_email_page.dart';
import 'package:frontend/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:frontend/features/auth/presentation/pages/verify_code_page.dart';
import 'package:frontend/features/auth/presentation/pages/reset_password_page.dart';
import 'package:frontend/features/ride_discovery/presentation/pages/ride_discovery_page.dart';
import 'package:frontend/features/ride_discovery/presentation/pages/bus_profile_page.dart';
import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';

import 'package:frontend/shared/widgets/navigation_bar/commuter_scaffold.dart';
import 'package:frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend/features/profile/presentation/pages/settings_page.dart';
import 'package:frontend/features/profile/presentation/pages/ride_history_page.dart';
import 'package:frontend/features/profile/presentation/pages/trusted_contacts_page.dart';
import 'package:frontend/features/safety/presentation/pages/safety_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    StatefulShellRoute(
      builder: (context, state, navigationShell) =>
          CommuterScaffold(navigationShell: navigationShell),
      navigatorContainerBuilder: (context, navigationShell, children) =>
          AnimatedBranchContainer(
        currentIndex: navigationShell.currentIndex,
        children: children,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) {
                final lat = double.tryParse(state.uri.queryParameters['lat'] ?? '');
                final lon = double.tryParse(state.uri.queryParameters['lon'] ?? '');
                final name = state.uri.queryParameters['name'];

                return MapPage(
                  title: 'Home',
                  initialLat: lat,
                  initialLon: lon,
                  sharedPersonName: name,
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/planner',
              builder: (context, state) =>
                  const RideDiscoveryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/safety',
              builder: (context, state) =>
                  const SafetyPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    // Auth and Onboarding Routes
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          slideTransitionPage(state: state, child: const LoginPage()),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) =>
          slideTransitionPage(state: state, child: const SignupPage()),
    ),
    GoRoute(
      path: '/check_email',
      pageBuilder: (context, state) {
        final email = state.extra as String?;
        return slideTransitionPage(
          state: state,
          child: CheckEmailPage(email: email),
        );
      },
    ),
    GoRoute(
      path: '/forgot_password',
      pageBuilder: (context, state) =>
          slideTransitionPage(state: state, child: const ForgotPasswordPage()),
    ),
    GoRoute(
      path: '/verify_code',
      builder: (context, state) {
        final email = state.extra as String?;
        return VerifyCodePage(email: email);
      },
    ),
    GoRoute(
      path: '/reset_password',
      builder: (context, state) {
        final email = state.extra as String?;
        return ResetPasswordPage(email: email);
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          slideTransitionPage(state: state, child: const SettingsPage()),
    ),
    GoRoute(
      path: '/ride_history',
      pageBuilder: (context, state) =>
          slideTransitionPage(state: state, child: const RideHistoryPage()),
    ),
    GoRoute(
      path: '/trusted_contacts',
      pageBuilder: (context, state) => slideTransitionPage(
        state: state,
        child: const TrustedContactsPage(),
      ),
    ),
    GoRoute(
      path: '/bus_profile',
      pageBuilder: (context, state) {
        final ride = state.extra as Ride;
        return slideTransitionPage(state: state, child: BusProfilePage(ride: ride));
      },
    ),
  ],
);

class CommuterApp extends StatelessWidget {
  const CommuterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Commuter App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: _router,
    );
  }
}
