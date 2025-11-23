import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/creation_provider.dart';

class MagicLoadingScreen extends ConsumerWidget {
  const MagicLoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationControllerProvider);

    // Prevent back navigation while generating
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.deepBackground,
        body: Stack(
          children: [
            // Rive Animation (Background/Center)
            Center(
              child: SizedBox(
                height: 300,
                width: 300,
                child: RiveAnimation.asset(
                  'assets/rive/magic.riv', // Ensure this asset exists or use placeholder
                  fit: BoxFit.contain,
                  placeHolder: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              ),
            ),

            // Status Text
            Positioned(
              bottom: 100,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Text(
                    state.currentStepMessage ?? "Creating Magic...",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    color: AppColors.primaryPurple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
