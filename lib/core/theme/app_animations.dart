import 'package:flutter/material.dart';

/// Comprehensive animation system for the Dualify Dashboard
/// Contains all animation constants, curves, and configurations
class AppAnimations {
  // Private constructor to prevent instantiation
  AppAnimations._();

  // Duration Constants
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);

  // Specific animation durations
  static const Duration cardHover = Duration(milliseconds: 200);
  static const Duration cardHoverDuration = Duration(milliseconds: 200);
  static const Duration progressAnimation = Duration(milliseconds: 1200);
  static const Duration emojiPop = Duration(milliseconds: 150);
  static const Duration toastSlide = Duration(milliseconds: 300);
  static const Duration refreshRotation = Duration(milliseconds: 800);
  static const Duration refreshRotationDuration = Duration(milliseconds: 800);
  static const Duration shimmerAnimation = Duration(milliseconds: 1500);
  static const Duration fadeTransition = Duration(milliseconds: 250);
  static const Duration slideTransition = Duration(milliseconds: 300);
  static const Duration scaleTransition = Duration(milliseconds: 200);

  // Animation Curves
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve decelerate = Curves.decelerate;
  static const Curve linear = Curves.linear;

  // Custom curves
  static const Curve cardHoverCurve = Curves.easeOutCubic;
  static const Curve progressCurve = Curves.easeInOutCubic;
  static const Curve emojiPopCurve = Curves.elasticOut;
  static const Curve toastCurve = Curves.easeOutBack;
  static const Curve shimmerCurve = Curves.easeInOut;

  // Transform Values
  static const double hoverScale = 1.02;
  static const double pressedScale = 0.98;
  static const double activeScale = 1.05;
  static const double popScale = 1.15;

  // Translation values
  static const double hoverTranslateY = -2.0;
  static const double pressedTranslateY = 1.0;
  static const double slideInDistance = 50.0;
  static const double slideOutDistance = -50.0;

  // Rotation values
  static const double refreshRotationAngle =
      2 * 3.14159; // 360 degrees in radians
  static const double emojiRotation =
      0.1; // Slight rotation for emoji interaction

  // Opacity values
  static const double fadeInStart = 0.0;
  static const double fadeInEnd = 1.0;
  static const double hoverOpacity = 0.8;
  static const double disabledOpacity = 0.5;

  // Specific Animation Configurations

  /// Card hover animation configuration
  static AnimationConfiguration get cardHoverConfig => AnimationConfiguration(
    duration: cardHoverDuration,
    curve: cardHoverCurve,
    scale: hoverScale,
    translateY: hoverTranslateY,
  );

  /// Progress circle animation configuration
  static AnimationConfiguration get progressCircle => AnimationConfiguration(
    duration: progressAnimation,
    curve: progressCurve,
    scale: 1.0,
  );

  /// Emoji pop animation configuration
  static AnimationConfiguration get emojiInteraction => AnimationConfiguration(
    duration: emojiPop,
    curve: emojiPopCurve,
    scale: popScale,
    rotation: emojiRotation,
  );

  /// Toast slide-in animation configuration
  static AnimationConfiguration get toastSlideIn => AnimationConfiguration(
    duration: toastSlide,
    curve: toastCurve,
    translateY: slideInDistance,
    opacity: fadeInStart,
  );

  /// Shimmer loading animation configuration
  static AnimationConfiguration get shimmerLoading => AnimationConfiguration(
    duration: shimmerAnimation,
    curve: shimmerCurve,
    repeat: true,
  );

  /// Fade transition configuration
  static AnimationConfiguration get fadeIn => AnimationConfiguration(
    duration: fadeTransition,
    curve: easeOut,
    opacity: fadeInStart,
  );

  /// Scale transition configuration
  static AnimationConfiguration get scaleIn => AnimationConfiguration(
    duration: scaleTransition,
    curve: easeOut,
    scale: 0.8,
  );

  /// Slide transition configuration
  static AnimationConfiguration get slideUp => AnimationConfiguration(
    duration: slideTransition,
    curve: easeOut,
    translateY: slideInDistance,
  );

  // Animation Builder Methods

  /// Creates a hover animation for cards and interactive elements
  static Widget buildHoverAnimation({
    required Widget child,
    required bool isHovered,
    VoidCallback? onTap,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedContainer(
      duration: duration ?? cardHover,
      curve: curve ?? cardHoverCurve,
      transform:
          Matrix4.identity()
            ..scale(isHovered ? hoverScale : 1.0)
            ..translate(0.0, isHovered ? hoverTranslateY : 0.0),
      child: GestureDetector(onTap: onTap, child: child),
    );
  }

  /// Creates a press animation for buttons
  static Widget buildPressAnimation({
    required Widget child,
    required bool isPressed,
    VoidCallback? onTap,
    Duration? duration,
  }) {
    return AnimatedContainer(
      duration: duration ?? fast,
      curve: easeOut,
      transform:
          Matrix4.identity()
            ..scale(isPressed ? pressedScale : 1.0)
            ..translate(0.0, isPressed ? pressedTranslateY : 0.0),
      child: GestureDetector(onTap: onTap, child: child),
    );
  }

  /// Creates a fade transition
  static Widget buildFadeTransition({
    required Animation<double> animation,
    required Widget child,
    Curve? curve,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: curve ?? easeOut),
      child: child,
    );
  }

  /// Creates a scale transition
  static Widget buildScaleTransition({
    required Animation<double> animation,
    required Widget child,
    Curve? curve,
    double? scale,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: scale ?? 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: curve ?? easeOut)),
      child: child,
    );
  }

  /// Creates a slide transition
  static Widget buildSlideTransition({
    required Animation<double> animation,
    required Widget child,
    Offset? begin,
    Curve? curve,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin ?? const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: curve ?? easeOut)),
      child: child,
    );
  }

  /// Creates a rotation transition
  static Widget buildRotationTransition({
    required Animation<double> animation,
    required Widget child,
    double? turns,
    Curve? curve,
  }) {
    return RotationTransition(
      turns: Tween<double>(
        begin: 0.0,
        end: turns ?? 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: curve ?? linear)),
      child: child,
    );
  }

  /// Creates a shimmer effect for loading states
  static Widget buildShimmerEffect({
    required Widget child,
    required bool isLoading,
    Color? baseColor,
    Color? highlightColor,
  }) {
    if (!isLoading) return child;

    return AnimatedContainer(
      duration: shimmerAnimation,
      curve: shimmerCurve,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor ?? Colors.grey[300]!,
            highlightColor ?? Colors.grey[100]!,
            baseColor ?? Colors.grey[300]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }

  /// Creates a staggered animation for lists
  static Widget buildStaggeredAnimation({
    required int index,
    required Widget child,
    Duration? delay,
    Duration? duration,
  }) {
    final animationDelay = delay ?? const Duration(milliseconds: 100);
    final totalDelay = Duration(
      milliseconds: animationDelay.inMilliseconds * index,
    );

    return AnimatedContainer(
      duration: duration ?? medium,
      curve: easeOut,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: totalDelay,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: child,
      ),
    );
  }
}

/// Configuration class for animations
class AnimationConfiguration {
  final Duration duration;
  final Curve curve;
  final double? scale;
  final double? translateX;
  final double? translateY;
  final double? rotation;
  final double? opacity;
  final bool repeat;

  const AnimationConfiguration({
    required this.duration,
    required this.curve,
    this.scale,
    this.translateX,
    this.translateY,
    this.rotation,
    this.opacity,
    this.repeat = false,
  });

  /// Creates a copy with modified values
  AnimationConfiguration copyWith({
    Duration? duration,
    Curve? curve,
    double? scale,
    double? translateX,
    double? translateY,
    double? rotation,
    double? opacity,
    bool? repeat,
  }) {
    return AnimationConfiguration(
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      scale: scale ?? this.scale,
      translateX: translateX ?? this.translateX,
      translateY: translateY ?? this.translateY,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      repeat: repeat ?? this.repeat,
    );
  }
}

/// Predefined animation presets
class AnimationPresets {
  static const AnimationConfiguration fadeIn = AnimationConfiguration(
    duration: AppAnimations.fadeTransition,
    curve: AppAnimations.easeOut,
    opacity: 0.0,
  );

  static const AnimationConfiguration slideUp = AnimationConfiguration(
    duration: AppAnimations.slideTransition,
    curve: AppAnimations.easeOut,
    translateY: AppAnimations.slideInDistance,
  );

  static const AnimationConfiguration scaleIn = AnimationConfiguration(
    duration: AppAnimations.scaleTransition,
    curve: AppAnimations.easeOut,
    scale: 0.8,
  );

  static const AnimationConfiguration bounceIn = AnimationConfiguration(
    duration: AppAnimations.medium,
    curve: AppAnimations.bounceOut,
    scale: 0.3,
  );

  static const AnimationConfiguration elasticIn = AnimationConfiguration(
    duration: AppAnimations.slow,
    curve: AppAnimations.elasticOut,
    scale: 0.0,
  );
}
