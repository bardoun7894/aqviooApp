import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/services/remote_config_service.dart';
import '../../data/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;
  late Animation<double> _glowPulse;
  late Animation<double> _shimmerPosition;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Particle animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Glow pulse controller
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Shimmer effect controller
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Logo animations
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _glowPulse = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _shimmerPosition = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Start animation sequence
    _logoController.forward();

    // Wait for auth state to resolve, then navigate
    _waitForAuthAndNavigate();
  }

  Future<void> _waitForAuthAndNavigate() async {
    // Minimum display time for splash animation
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    //s

    // Wait for auth state to settle (up to 5 seconds)
    final authState = ref.read(authStateProvider);
    if (authState.isLoading) {
      try {
        await ref
            .read(authStateProvider.future)
            .timeout(const Duration(seconds: 5), onTimeout: () => false);
      } catch (_) {
        // On any error, proceed to login
      }
      if (!mounted) return;
    }

    _navigate();
  }

  void _navigate() {
    final authState = ref.read(authStateProvider);

    if (authState.value == true) {
      // User is authenticated - ensure API keys are synced to Firestore
      RemoteConfigService().ensureKeysInFirestore();
      context.go('/home');
    } else {
      // Auth resolved to false OR timed out - go to login either way
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFAFAFF),
              AppColors.backgroundLight,
              const Color(0xFFF0EFFF),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles background
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_particleController.value),
                  size: Size.infinite,
                );
              },
            ),

            // Gradient blobs with enhanced animation
            Positioned(
              top: -100,
              right: -100,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _glowPulse.value,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryPurple.withOpacity(0.15),
                            AppColors.primaryPurple.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              bottom: -80,
              left: -80,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.1 - (_glowPulse.value - 0.8) / 2,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF82C8F7).withOpacity(0.12),
                            const Color(0xFF82C8F7).withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _logoController,
                  _glowController,
                  _shimmerController,
                ]),
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with multiple animation layers
                      Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow ring
                                Container(
                                  width: 180 * _glowPulse.value,
                                  height: 180 * _glowPulse.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.primaryPurple.withOpacity(
                                          0.0,
                                        ),
                                        AppColors.primaryPurple.withOpacity(
                                          0.15,
                                        ),
                                        AppColors.primaryPurple.withOpacity(
                                          0.0,
                                        ),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),

                                // Glassmorphic container
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.7),
                                        Colors.white.withOpacity(0.5),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.8),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryPurple
                                            .withOpacity(0.2),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.8),
                                        blurRadius: 10,
                                        spreadRadius: -5,
                                        offset: const Offset(-5, -5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 15,
                                        sigmaY: 15,
                                      ),
                                      child: Stack(
                                        children: [
                                          // Logo image
                                          Center(
                                            child: Image.asset(
                                              'assets/images/logo.png',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                // Fallback icon if logo.png not found
                                                return Icon(
                                                  Icons.auto_awesome,
                                                  size: 60,
                                                  color:
                                                      AppColors.primaryPurple,
                                                );
                                              },
                                            ),
                                          ),

                                          // Shimmer overlay effect
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              child: Transform.translate(
                                                offset: Offset(
                                                  _shimmerPosition.value * 200,
                                                  0,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                      colors: [
                                                        Colors.white
                                                            .withOpacity(0.0),
                                                        Colors.white
                                                            .withOpacity(0.3),
                                                        Colors.white
                                                            .withOpacity(0.0),
                                                      ],
                                                      stops: const [
                                                        0.0,
                                                        0.5,
                                                        1.0,
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 40.scaleH(context)),

                      // Aqvioo text with fade-in and slide up
                      Transform.translate(
                        offset: Offset(0, 20 * (1 - _logoOpacity.value)),
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  AppColors.primaryPurple,
                                  AppColors.primaryPurple.withOpacity(0.8),
                                  AppColors.gradientBlobBlue,
                                ],
                              ).createShader(bounds);
                            },
                            child: Text(
                              'Aqvioo',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                    height: 1,
                                  ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 8.scaleH(context)),

                      // Subtitle with fade
                      Opacity(
                        opacity: _logoOpacity.value * 0.8,
                        child: Text(
                          'AI-Powered Content Creation',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF6B7280),
                                    letterSpacing: 0.5,
                                  ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Particle painter for ambient background effect
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primaryPurple.withOpacity(0.05);

    // Generate consistent particles
    final random = math.Random(42);
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final offset = math.sin(animationValue * 2 * math.pi + i) * 10;

      canvas.drawCircle(
        Offset(x, y + offset),
        random.nextDouble() * 3 + 1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
