import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Verify Rive asset exists or handle error gracefully
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: _hasError
                  ? const Icon(Icons.auto_awesome, size: 100, color: AppColors.primaryPurple)
                  : RiveAnimation.asset(
                      'assets/rive/splash.riv',
                      fit: BoxFit.contain,
                      placeHolder: const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryPurple),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aqvioo',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
