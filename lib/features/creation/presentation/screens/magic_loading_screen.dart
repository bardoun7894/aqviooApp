import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/simple_animations.dart';
import '../../../../generated/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';

import 'package:go_router/go_router.dart';
import '../../domain/models/creation_config.dart';
import '../providers/creation_provider.dart';
import '../widgets/magic_animation.dart';

class MagicLoadingScreen extends ConsumerWidget {
  const MagicLoadingScreen({super.key});

  String _translateStepMessage(String? key, BuildContext context) {
    if (key == null) {
      return AppLocalizations.of(context)!.creatingMagic;
    }
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'enhancingIdea':
        return l10n.enhancingIdea;
      case 'preparingPrompt':
        return l10n.preparingPrompt;
      case 'bringingImageToLife':
        return l10n.bringingImageToLife;
      case 'creatingVideo':
        return l10n.creatingVideo;
      case 'generatingImage':
        return l10n.generatingImage;
      case 'creatingMasterpiece':
        return l10n.creatingMasterpiece;
      case 'magicComplete':
        return l10n.magicComplete;
      case 'generationTimedOut':
        return l10n.generationTimedOut;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(creationControllerProvider, (previous, next) {
      if (next.status == CreationWizardStatus.success &&
          next.videoUrl != null) {
        // Navigate to preview/result
        context.pushReplacement('/preview', extra: {
          'videoUrl': next.videoUrl,
          'prompt': next.config.prompt,
          'isImage': next.config.outputType == OutputType.image,
        });
      }
    });

    final state = ref.watch(creationControllerProvider);

    // Handle case where state is already success when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.status == CreationWizardStatus.success &&
          state.videoUrl != null) {
        context.pushReplacement('/preview', extra: {
          'videoUrl': state.videoUrl,
          'prompt': state.config.prompt,
          'isImage': state.config.outputType == OutputType.image,
        });
      }
    });

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            SizedBox(height: constraints.maxHeight * 0.08),

                            // Magic Animation (Centered)
                            const MagicAnimation(
                                size: 200, color: Colors.white),

                            SizedBox(height: 32.scaleH(context)),

                            // Status Text
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                _translateStepMessage(
                                    state.currentStepMessage, context),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Step Indicators
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildStepIndicator(
                                    context,
                                    icon: Icons.auto_awesome,
                                    label: AppLocalizations.of(context)!
                                        .scriptStep,
                                    isActive: state.status ==
                                        CreationWizardStatus.generatingScript,
                                    isCompleted: state.status.index >
                                        CreationWizardStatus
                                            .generatingScript.index,
                                  ),
                                  _buildStepConnector(
                                    isActive: state.status.index >
                                        CreationWizardStatus
                                            .generatingScript.index,
                                  ),
                                  _buildStepIndicator(
                                    context,
                                    icon: Icons.graphic_eq,
                                    label:
                                        AppLocalizations.of(context)!.audioStep,
                                    isActive: state.status ==
                                        CreationWizardStatus.generatingAudio,
                                    isCompleted: state.status.index >
                                        CreationWizardStatus
                                            .generatingAudio.index,
                                  ),
                                  _buildStepConnector(
                                    isActive: state.status.index >
                                        CreationWizardStatus
                                            .generatingAudio.index,
                                  ),
                                  _buildStepIndicator(
                                    context,
                                    icon: Icons.video_library,
                                    label:
                                        AppLocalizations.of(context)!.videoStep,
                                    isActive: state.status ==
                                        CreationWizardStatus.generatingVideo,
                                    isCompleted: state.status ==
                                        CreationWizardStatus.success,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: context.screenHeight * 0.15),

                            // Progress Bar
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
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
                                    duration:
                                        const Duration(milliseconds: 1500),
                                    builder: (context, value, child) {
                                      return LinearProgressIndicator(
                                        backgroundColor:
                                            Colors.white.withOpacity(0.2),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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

                            SizedBox(height: 24.scaleH(context)),

                            // Info Message
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .backgroundGenerationInfo,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Minimize Button
                            TextButton.icon(
                              onPressed: () {
                                ref
                                    .read(creationControllerProvider.notifier)
                                    .minimizeTask();
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white70),
                              label: Text(
                                AppLocalizations.of(context)!
                                    .checkLaterInMyCreations,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                backgroundColor: Colors.white.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 40.scaleH(context)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
