import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../../../core/theme/app_colors.dart';

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
            CustomAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 4),
              builder: (context, value, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(
                          const Color(0xFFA855F7),
                          const Color(0xFF8B5CF6),
                          value,
                        )!,
                        Color.lerp(
                          const Color(0xFF8B5CF6),
                          const Color(0xFF6366F1),
                          value,
                        )!,
                        Color.lerp(
                          const Color(0xFF6366F1),
                          const Color(0xFFA855F7),
                          value,
                        )!,
                      ],
                    ),
                  ),
                );
              },
              control: Control.mirror,
            ),

            // Glass Overlay Pattern
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.15)),
            ),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Magic Animation (Centered)
                  const MagicAnimation(size: 200, color: Colors.white),

                  const SizedBox(height: 48),

                  // Status Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      state.currentStepMessage ?? "Creating Magic...",
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Step Indicators
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStepIndicator(
                          context,
                          icon: Icons.auto_awesome,
                          label: 'Script',
                          isActive:
                              state.status == CreationStatus.generatingScript,
                          isCompleted: state.status.index >
                              CreationStatus.generatingScript.index,
                        ),
                        _buildStepConnector(
                          isActive: state.status.index >
                              CreationStatus.generatingScript.index,
                        ),
                        _buildStepIndicator(
                          context,
                          icon: Icons.graphic_eq,
                          label: 'Audio',
                          isActive:
                              state.status == CreationStatus.generatingAudio,
                          isCompleted: state.status.index >
                              CreationStatus.generatingAudio.index,
                        ),
                        _buildStepConnector(
                          isActive: state.status.index >
                              CreationStatus.generatingAudio.index,
                        ),
                        _buildStepIndicator(
                          context,
                          icon: Icons.video_library,
                          label: 'Video',
                          isActive:
                              state.status == CreationStatus.generatingVideo,
                          isCompleted: state.status == CreationStatus.success,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1500),
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.9),
                              ),
                              minHeight: 6,
                              value: value,
                            );
                          },
                          control: Control.mirror,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive || isCompleted
                ? Colors.white
                : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(isActive ? 1.0 : 0.4),
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isActive || isCompleted
                ? AppColors.primaryPurple
                : Colors.white.withOpacity(0.6),
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color:
                Colors.white.withOpacity(isActive || isCompleted ? 1.0 : 0.7),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isActive}) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isActive ? 0.8 : 0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
