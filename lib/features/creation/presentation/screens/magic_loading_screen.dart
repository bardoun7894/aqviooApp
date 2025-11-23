import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/glass_container.dart';
import '../providers/creation_provider.dart';
import '../widgets/magic_animation.dart';

class MagicLoadingScreen extends ConsumerWidget {
  const MagicLoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationControllerProvider);

    // Prevent back navigation while generating
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // Animated Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),

            // Glass Overlay Pattern
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.2)),
            ),

            // Magic Animation (Centered)
            const Center(
              child: MagicAnimation(size: 300, color: AppColors.primaryPurple),
            ),

            // Status Text
            Positioned(
              bottom: 100,
              left: 24,
              right: 24,
              child: GlassContainer(
                opacity: 0.1,
                blur: 10,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      state.currentStepMessage ?? "Creating Magic...",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.darkGray,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      backgroundColor: AppColors.primaryPurple.withValues(
                        alpha: 0.1,
                      ),
                      color: AppColors.primaryPurple,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
