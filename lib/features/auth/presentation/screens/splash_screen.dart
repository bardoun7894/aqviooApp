import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_gradient_blob.dart';
import '../../data/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds before navigating
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _navigate();
    });
  }

  void _navigate() {
    final authState = ref.read(authStateProvider);

    if (authState.value == true) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Solid white background
          Container(color: Colors.white),

          // Animated gradient blob (pulsing effect)
          const Center(
            child: AnimatedGradientBlob(
              size: 256,
              colors: [
                AppColors.gradientBlobPurple,
                AppColors.gradientBlobPurpleLight,
              ],
              duration: Duration(seconds: 4),
              minScale: 0.95,
              maxScale: 1.05,
              minOpacity: 0.8,
              maxOpacity: 1.0,
              blurRadius: 48,
            ),
          ),

          // Logo container with glassmorphism
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Icon(
                    Icons.check_circle,
                    size: 48,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ),
          ),

          // Aqvioo text below logo
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 120), // Space below logo
                Text(
                  'Aqvioo',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: const Color(0xFF334155), // slate-800
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
