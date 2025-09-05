import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import 'dart:math' as math;

class LoadingPerformanceConfig {
  static const bool enableParticles = false;
  static const bool enableComplexAnimations = false;
  static const int particleCount = 5;
  static const Duration animationDuration = Duration(milliseconds: 1500);
  static const bool enableShadows = false;
}

class OptimizedLoadingScreen extends StatefulWidget {
  final String? message;
  final bool showLogo;
  final VoidCallback? onComplete;
  final Duration? duration;
  final bool lightweightMode;

  const OptimizedLoadingScreen({
    super.key,
    this.message,
    this.showLogo = true,
    this.onComplete,
    this.duration,
    this.lightweightMode = true,
  });

  @override
  State<OptimizedLoadingScreen> createState() => _OptimizedLoadingScreenState();
}

class _OptimizedLoadingScreenState extends State<OptimizedLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: LoadingPerformanceConfig.animationDuration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.linear,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeIn,
    ));

    _startAnimation();

    if (widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (mounted && widget.onComplete != null) {
          widget.onComplete!();
        }
      });
    }
  }

  void _startAnimation() {
    _mainController.forward();
    if (!widget.lightweightMode && LoadingPerformanceConfig.enableComplexAnimations) {
      _mainController.repeat();
    } else {
      _mainController.forward();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0B0F),
        ),
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.showLogo) ...[
                      _buildSimpleLogo(),
                      const SizedBox(height: 32),
                    ],

                    _buildSimpleSpinner(),

                    const SizedBox(height: 24),

                    _buildLoadingText(),

                    const SizedBox(height: 16),

                    if (widget.lightweightMode)
                      _buildSimpleProgressIndicator()
                    else
                      _buildProgressDots(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSimpleLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF6366F1).withValues(alpha: 0.2),
        border: Border.all(
          color: const Color(0xFF6366F1),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Image.asset(
          'assets/plume_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1),
              ),
              child: const Icon(
                Icons.rocket_launch,
                color: Colors.white,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSimpleSpinner() {
    if (widget.lightweightMode) {
      return SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            const Color(0xFF6366F1),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF6366F1),
                width: 3,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF06B6D4),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingText() {
    return Column(
      children: [
        Text(
          widget.message ?? 'Loading...',
          style: AppFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        if (!widget.lightweightMode) ...[
          const SizedBox(height: 8),
          Text(
            'Please wait...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildSimpleProgressIndicator() {
    return Container(
      width: 100,
      height: 3,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: null,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFF6366F1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressDots() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final progress = (_mainController.value + delay) % 1.0;
            final opacity = (math.sin(progress * math.pi * 2) + 1) / 2;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: opacity * 0.8),
              ),
            );
          }),
        );
      },
    );
  }
}

class MinimalLoadingScreen extends StatelessWidget {
  final String? message;

  const MinimalLoadingScreen({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0A0B0F),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message ?? 'Loading...',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingScreenFactory {
  static Widget create({
    String? message,
    bool showLogo = true,
    VoidCallback? onComplete,
    Duration? duration,
  }) {
    return OptimizedLoadingScreen(
      message: message,
      showLogo: showLogo,
      onComplete: onComplete,
      duration: duration,
      lightweightMode: true,
    );
  }

  static Widget createMinimal({String? message}) {
    return MinimalLoadingScreen(message: message);
  }
}
