import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_animations/simple_animations.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../core/utils/responsive_extensions.dart';

import 'package:go_router/go_router.dart';
import '../../domain/models/creation_config.dart';
import '../providers/creation_provider.dart';
import '../widgets/magic_animation.dart';

class MagicLoadingScreen extends ConsumerWidget {
  const MagicLoadingScreen({super.key});

  String _translateStepMessage(
      String? key, BuildContext context, bool isImage) {
    if (key == null) {
      return isImage
          ? AppLocalizations.of(context)!.generatingImage
          : AppLocalizations.of(context)!.creatingVideo;
    }
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'enhancingIdea':
        return isImage ? l10n.enhancingImageIdea : l10n.enhancingVideoIdea;
      case 'preparingPrompt':
        return isImage ? l10n.preparingImagePrompt : l10n.preparingVideoPrompt;
      case 'bringingImageToLife':
        return l10n.bringingImageToLife;
      case 'creatingVideo':
        return l10n.creatingVideo;
      case 'generatingImage':
        return l10n.generatingImage;
      case 'creatingMasterpiece':
        return isImage
            ? l10n.creatingImageMasterpiece
            : l10n.creatingVideoMasterpiece;
      case 'magicComplete':
        return isImage ? l10n.imageComplete : l10n.videoComplete;
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
    final isImage = state.config.outputType == OutputType.image;

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
            // Animated Gradient Background - App theme colors
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
              child: Container(color: Colors.black.withValues(alpha: 0.1)),
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
                            SizedBox(height: constraints.maxHeight * 0.06),

                            // Content Type Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isImage
                                        ? Icons.image_rounded
                                        : Icons.videocam_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isImage
                                        ? AppLocalizations.of(context)!
                                            .generatingImageTitle
                                        : AppLocalizations.of(context)!
                                            .generatingVideoTitle,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24.scaleH(context)),

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
                                    state.currentStepMessage, context, isImage),
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Step Indicators - Show different steps based on output type
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: isImage
                                    ? [
                                        // Image generation steps (simpler)
                                        _buildStepIndicator(
                                          context,
                                          icon: Icons.auto_awesome,
                                          label: AppLocalizations.of(context)!
                                              .scriptStep,
                                          isActive: state.status ==
                                              CreationWizardStatus
                                                  .generatingScript,
                                          isCompleted: state.status.index >
                                              CreationWizardStatus
                                                  .generatingScript.index,
                                          primaryColor: const Color(0xFFA855F7),
                                        ),
                                        _buildStepConnector(
                                          isActive: state.status.index >
                                              CreationWizardStatus
                                                  .generatingScript.index,
                                        ),
                                        _buildStepIndicator(
                                          context,
                                          icon: Icons.image_rounded,
                                          label: AppLocalizations.of(context)!
                                              .image,
                                          isActive: state.status ==
                                              CreationWizardStatus
                                                  .generatingVideo,
                                          isCompleted: state.status ==
                                              CreationWizardStatus.success,
                                          primaryColor: const Color(0xFFA855F7),
                                        ),
                                      ]
                                    : [
                                        // Video generation steps
                                        _buildStepIndicator(
                                          context,
                                          icon: Icons.auto_awesome,
                                          label: AppLocalizations.of(context)!
                                              .scriptStep,
                                          isActive: state.status ==
                                              CreationWizardStatus
                                                  .generatingScript,
                                          isCompleted: state.status.index >
                                              CreationWizardStatus
                                                  .generatingScript.index,
                                          primaryColor: const Color(0xFFA855F7),
                                        ),
                                        _buildStepConnector(
                                          isActive: state.status.index >
                                              CreationWizardStatus
                                                  .generatingScript.index,
                                        ),
                                        _buildStepIndicator(
                                          context,
                                          icon: Icons.graphic_eq,
                                          label: AppLocalizations.of(context)!
                                              .audioStep,
                                          isActive: state.status ==
                                              CreationWizardStatus
                                                  .generatingAudio,
                                          isCompleted: state.status.index >
                                              CreationWizardStatus
                                                  .generatingAudio.index,
                                          primaryColor: const Color(0xFFA855F7),
                                        ),
                                        _buildStepConnector(
                                          isActive: state.status.index >
                                              CreationWizardStatus
                                                  .generatingAudio.index,
                                        ),
                                        _buildStepIndicator(
                                          context,
                                          icon: Icons.video_library,
                                          label: AppLocalizations.of(context)!
                                              .video,
                                          isActive: state.status ==
                                              CreationWizardStatus
                                                  .generatingVideo,
                                          isCompleted: state.status ==
                                              CreationWizardStatus.success,
                                          primaryColor: const Color(0xFFA855F7),
                                        ),
                                      ],
                              ),
                            ),

                            SizedBox(height: context.screenHeight * 0.1),

                            // Progress Bar
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CustomAnimationBuilder<double>(
                                        tween:
                                            Tween<double>(begin: 0.0, end: 1.0),
                                        duration:
                                            const Duration(milliseconds: 1500),
                                        builder: (context, value, child) {
                                          return LinearProgressIndicator(
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.2),
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(
                                              Colors.white,
                                            ),
                                            minHeight: 6,
                                            value: value,
                                          );
                                        },
                                        control: Control.mirror,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 20.scaleH(context)),

                            // Info Message
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        isImage
                                            ? Icons.photo_library_rounded
                                            : Icons.movie_creation_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .backgroundGenerationInfo,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Minimize Button - redirect to my-creations
                            TextButton.icon(
                              onPressed: () {
                                ref
                                    .read(creationControllerProvider.notifier)
                                    .minimizeTask();
                                // Navigate to my-creations to see the generating card
                                context.go('/my-creations');
                              },
                              icon: const Icon(Icons.video_library_rounded,
                                  color: Colors.white, size: 20),
                              label: Text(
                                AppLocalizations.of(context)!
                                    .checkLaterInMyCreations,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 32.scaleH(context)),
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
    required Color primaryColor,
  }) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isActive || isCompleted
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.4),
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : icon,
            color: isActive || isCompleted
                ? primaryColor
                : Colors.white.withValues(alpha: 0.6),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white
                .withValues(alpha: isActive || isCompleted ? 1.0 : 0.7),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isActive}) {
    return Container(
      width: 36,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isActive ? 0.8 : 0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
