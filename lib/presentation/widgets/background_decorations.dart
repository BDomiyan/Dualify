import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../core/theme/app_colors.dart';

/// Decorative background icons for the login screen
/// Shows scattered Material Icons with educational/apprenticeship theme
class LoginBackgroundIcons extends StatefulWidget {
  final double opacity;
  final List<IconData>? customIcons;

  const LoginBackgroundIcons({
    super.key,
    this.opacity = 0.15,
    this.customIcons,
  });

  @override
  State<LoginBackgroundIcons> createState() => _LoginBackgroundIconsState();
}

class _LoginBackgroundIconsState extends State<LoginBackgroundIcons>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _rotationAnimations;
  late List<Animation<double>> _scaleAnimations;
  late List<BackgroundIcon> _icons;

  @override
  void initState() {
    super.initState();
    _generateIcons();
    _setupAnimations();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Constants
  static const int _iconCount = 12;
  static const int _randomSeed = 42;
  static const double _minIconSize = 20.0;
  static const double _maxIconSizeRange = 40.0;
  static const int _maxAnimationDelay = 2000;

  void _generateIcons() {
    final defaultIcons = [
      Icons.school_outlined,
      Icons.edit_square,
      Icons.lightbulb_outline,
      Icons.psychology_outlined,
      Icons.trending_up_outlined,
      Icons.star_outline,
      Icons.workspace_premium_outlined,
      Icons.emoji_events_outlined,
      Icons.auto_stories_outlined,
      Icons.science_outlined,
      Icons.engineering_outlined,
      Icons.construction_outlined,
      Icons.handyman_outlined,
      Icons.build_outlined,
      Icons.settings_outlined,
      Icons.code_outlined,
      Icons.design_services_outlined,
      Icons.palette_outlined,
    ];

    final iconsToUse = widget.customIcons ?? defaultIcons;
    final random = math.Random(_randomSeed);

    _icons = List.generate(_iconCount, (index) {
      return BackgroundIcon(
        icon: iconsToUse[random.nextInt(iconsToUse.length)],
        position: Offset(random.nextDouble(), random.nextDouble()),
        size: _minIconSize + random.nextDouble() * _maxIconSizeRange,
        rotation: random.nextDouble() * 2 * math.pi,
        animationDelay: Duration(
          milliseconds: random.nextInt(_maxAnimationDelay),
        ),
      );
    });
  }

  // Animation constants
  static const int _baseAnimationDuration = 8000;
  static const int _animationDurationRange = 4000;
  static const double _minScale = 0.8;
  static const double _maxScale = 1.2;

  void _setupAnimations() {
    _controllers = [];
    _rotationAnimations = [];
    _scaleAnimations = [];

    for (int i = 0; i < _icons.length; i++) {
      final controller = AnimationController(
        duration: Duration(
          milliseconds:
              _baseAnimationDuration +
              math.Random(i).nextInt(_animationDurationRange),
        ),
        vsync: this,
      );

      final rotationAnimation = Tween<double>(
        begin: _icons[i].rotation,
        end: _icons[i].rotation + 2 * math.pi,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));

      final scaleAnimation = Tween<double>(
        begin: _minScale,
        end: _maxScale,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      _controllers.add(controller);
      _rotationAnimations.add(rotationAnimation);
      _scaleAnimations.add(scaleAnimation);

      Future.delayed(_icons[i].animationDelay, () {
        if (mounted) {
          controller.repeat();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children:
                  _icons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final icon = entry.value;

                    return AnimatedBuilder(
                      animation: Listenable.merge([
                        _rotationAnimations[index],
                        _scaleAnimations[index],
                      ]),
                      builder: (context, child) {
                        return Positioned(
                          left:
                              icon.position.dx * constraints.maxWidth -
                              icon.size / 2,
                          top:
                              icon.position.dy * constraints.maxHeight -
                              icon.size / 2,
                          child: Transform.rotate(
                            angle: _rotationAnimations[index].value,
                            child: Transform.scale(
                              scale: _scaleAnimations[index].value,
                              child: Icon(
                                icon.icon,
                                size: icon.size,
                                color: AppColors.loginIconsOverlay.withOpacity(
                                  widget.opacity,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
            );
          },
        ),
      ),
    );
  }
}

/// Data class for background icon configuration
class BackgroundIcon {
  final IconData icon;
  final Offset position; // Normalized position (0.0 - 1.0)
  final double size;
  final double rotation;
  final Duration animationDelay;

  const BackgroundIcon({
    required this.icon,
    required this.position,
    required this.size,
    required this.rotation,
    required this.animationDelay,
  });
}

/// Animated floating icons with parallax effect
class ParallaxBackgroundIcons extends StatefulWidget {
  final ScrollController? scrollController;
  final double parallaxFactor;
  final double opacity;

  const ParallaxBackgroundIcons({
    super.key,
    this.scrollController,
    this.parallaxFactor = 0.5,
    this.opacity = 0.1,
  });

  @override
  State<ParallaxBackgroundIcons> createState() =>
      _ParallaxBackgroundIconsState();
}

class _ParallaxBackgroundIconsState extends State<ParallaxBackgroundIcons>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  double _scrollOffset = 0.0;

  static const Duration _floatDuration = Duration(seconds: 6);
  static const double _floatRangeStart = -10.0;
  static const double _floatRangeEnd = 10.0;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: _floatDuration,
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: _floatRangeStart,
      end: _floatRangeEnd,
    ).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _floatController.repeat(reverse: true);

    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _floatController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (mounted) {
      setState(() {
        _scrollOffset = widget.scrollController?.offset ?? 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                _floatAnimation.value - (_scrollOffset * widget.parallaxFactor),
              ),
              child: const LoginBackgroundIcons(),
            );
          },
        ),
      ),
    );
  }
}

/// Minimal background pattern for subtle decoration
class MinimalBackgroundPattern extends StatelessWidget {
  final double opacity;
  final Color? color;

  const MinimalBackgroundPattern({super.key, this.opacity = 0.05, this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _PatternPainter(
            color: (color ?? AppColors.primary).withOpacity(opacity),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for background pattern
class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  static const double _gridSpacing = 60.0;
  static const double _gridStrokeWidth = 1.0;
  static const double _diagonalStrokeWidth = 0.5;
  static const double _diagonalSpacingMultiplier = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = _gridStrokeWidth
          ..style = PaintingStyle.stroke;

    // Draw grid pattern
    for (double x = 0; x < size.width; x += _gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += _gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw diagonal lines
    paint.strokeWidth = _diagonalStrokeWidth;
    for (
      double x = -size.height;
      x < size.width;
      x += _gridSpacing * _diagonalSpacingMultiplier
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
