import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Shared transition duration for pushed routes, kept short so it reads as
/// "smoother", not "slower".
const Duration kPageTransitionDuration = Duration(milliseconds: 220);

/// A [CustomTransitionPage] that slides [child] in from the right while
/// gently parallax-pushing the previous page to the left, and reverses the
/// same way on pop. Use for routes pushed on top of the current stack
/// (auth flow, settings, detail pages, etc).
CustomTransitionPage<T> slideTransitionPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: kPageTransitionDuration,
    reverseTransitionDuration: kPageTransitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final incoming = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final outgoing = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.25, 0),
      ).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic),
      );
      return SlideTransition(
        position: outgoing,
        child: SlideTransition(position: incoming, child: child),
      );
    },
  );
}
