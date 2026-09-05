import 'package:flutter/widgets.dart';

/// Branch container for [StatefulShellRoute] that behaves like the default
/// `StatefulShellRoute.indexedStack` (every branch stays mounted so its
/// navigation stack/scroll position/etc. survive tab switches) but animates
/// a horizontal slide when the active branch changes, sliding left or right
/// depending on whether the new tab sits before or after the old one in the
/// bottom nav order.
class AnimatedBranchContainer extends StatefulWidget {
  const AnimatedBranchContainer({
    required this.currentIndex,
    required this.children,
    super.key,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 260);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  int _previousIndex = 0;
  int _direction = 1;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant AnimatedBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _direction = widget.currentIndex > oldWidget.currentIndex ? 1 : -1;
      _isAnimating = true;
      _controller
        ..value = 0
        ..forward().whenCompleteOrCancel(() {
          if (mounted) setState(() => _isAnimating = false);
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          for (int i = 0; i < widget.children.length; i++) _buildBranch(i),
        ],
      ),
    );
  }

  Widget _buildBranch(int index) {
    final isCurrent = index == widget.currentIndex;
    final isOutgoing = _isAnimating && index == _previousIndex;

    if (!isCurrent && !isOutgoing) {
      // Keep mounted (state preserved) but invisible, non-interactive, and
      // not ticking - same tradeoff as the built-in IndexedStack container.
      return Offstage(
        child: TickerMode(enabled: false, child: widget.children[index]),
      );
    }

    // Bug fix: Home page not rendering on startup
    if (isCurrent && !_isAnimating) {
      return TickerMode(enabled: true, child: widget.children[index]);
    }

    return IgnorePointer(
      ignoring: !isCurrent,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final t = _animation.value;
          final offsetX = isCurrent ? (1 - t) * _direction : -t * _direction;
          return FractionalTranslation(
            translation: Offset(offsetX, 0),
            child: child,
          );
        },
        child: TickerMode(enabled: true, child: widget.children[index]),
      ),
    );
  }
}
