import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = AppBlur.defaultBlur,
    this.opacity = AppGlass.defaultOpacity,
    this.borderRadius,
    this.color,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(AppRadius.medium);
    final theme = Theme.of(context);
    
    // Determine the base color
    final baseColor = color ?? theme.colorScheme.surface;
    
    // We add a subtle white or light gradient border commonly seen in glassmorphism
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark 
        ? Colors.white.withValues(alpha: AppGlass.borderOpacity) 
        : Colors.white.withValues(alpha: AppGlass.borderOpacity * 2);

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: opacity),
              borderRadius: effectiveBorderRadius,
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor.withValues(alpha: opacity + 0.1),
                  baseColor.withValues(alpha: opacity - 0.1),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
