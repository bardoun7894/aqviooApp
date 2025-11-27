import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/glass_container.dart';

import 'package:akvioo/features/creation/domain/models/creation_config.dart';
import 'package:akvioo/features/creation/presentation/providers/creation_provider.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../../generated/app_localizations.dart';

class ReviewFinalizeStep extends ConsumerStatefulWidget {
  const ReviewFinalizeStep({super.key});

  @override
  ConsumerState<ReviewFinalizeStep> createState() => _ReviewFinalizeStepState();
}

class _ReviewFinalizeStepState extends ConsumerState<ReviewFinalizeStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(creationControllerProvider).config;
    final controller = ref.read(creationControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: GlassContainer(
        borderRadius: 24,
        blurIntensity: 15,
        opacity: 0.6,
        borderColor: AppColors.white.withOpacity(0.8),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Idea Section
            _buildAnimatedSection(
              index: 0,
              child: _buildSection(
                title: AppLocalizations.of(context)!.yourIdea,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.prompt,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (config.imagePath != null) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(config.imagePath!),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
                onEdit: () => controller.goToStep(0),
              ),
            ),

            const SizedBox(height: 24),

            // Settings Section
            _buildAnimatedSection(
              index: 1,
              child: _buildSection(
                title: AppLocalizations.of(context)!.settingsSection,
                child: _buildSettingsPreview(context, config),
                onEdit: () => controller.goToStep(1),
              ),
            ),

            const SizedBox(height: 24),

            // Cost Section
            _buildAnimatedSection(index: 2, child: _buildCostSection()),

            const SizedBox(height: 32),

            // Generate Button
            _buildAnimatedSection(
              index: 3,
              child: _buildGenerateButton(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            0.6 + (index * 0.1),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              index * 0.1,
              0.6 + (index * 0.1),
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required VoidCallback onEdit,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.glassBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.edit,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryPurple,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildSettingsPreview(BuildContext context, CreationConfig config) {
    final l10n = AppLocalizations.of(context)!;
    if (config.outputType == OutputType.video) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingRow(l10n.outputType, l10n.video),
          if (config.videoStyle != null)
            _buildSettingRow(l10n.style, config.videoStyle!.displayName),
          if (config.videoDurationSeconds != null)
            _buildSettingRow(l10n.duration, '${config.videoDurationSeconds}s'),
          if (config.videoAspectRatio != null)
            _buildSettingRow(
              l10n.aspectRatio,
              config.videoAspectRatio == 'landscape'
                  ? l10n.aspectRatio16x9
                  : l10n.aspectRatio9x16,
            ),
          if (config.voiceGender != null && config.voiceDialect != null)
            _buildSettingRow(
              l10n.voice,
              '${config.voiceGender == VoiceGender.female ? l10n.female : l10n.male} - ${_getDialectName(context, config.voiceDialect!)}',
            ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingRow(l10n.outputType, l10n.image),
          if (config.imageStyle != null)
            _buildSettingRow(l10n.style, config.imageStyle!.displayName),
          if (config.imageSize != null)
            _buildSettingRow(l10n.size, _getImageSizeName(context, config.imageSize!)),
        ],
      );
    }
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple.withOpacity(0.08),
            AppColors.primaryPurple.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.costSection,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.cost,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  AppLocalizations.of(context)!.currency,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPurple.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Check if user is guest
          final isAnonymous = ref.read(authRepositoryProvider).isAnonymous;

          if (isAnonymous) {
            final l10n = AppLocalizations.of(context)!;
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.loginRequired),
                content: Text(l10n.pleaseLoginToGenerate),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/login');
                    },
                    child: Text(l10n.login),
                  ),
                ],
              ),
            );
            return;
          }

          // Navigation to magic loading will be handled by listener in home_screen
          final controller = ref.read(creationControllerProvider.notifier);
          final config = ref.read(creationControllerProvider).config;

          controller.generateVideo(
            prompt: config.prompt,
            imagePath: config.imagePath,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 24),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.generateMagic,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDialectName(BuildContext context, String dialectCode) {
    final l10n = AppLocalizations.of(context)!;
    switch (dialectCode) {
      case 'ar-SA':
        return l10n.dialectSaudi;
      case 'ar-EG':
        return l10n.dialectEgyptian;
      case 'ar-AE':
        return l10n.dialectUAE;
      case 'ar-LB':
        return l10n.dialectLebanese;
      case 'ar-JO':
        return l10n.dialectJordanian;
      case 'ar-MA':
        return l10n.dialectMoroccan;
      default:
        return 'Arabic';
    }
  }

  String _getImageSizeName(BuildContext context, String size) {
    final l10n = AppLocalizations.of(context)!;
    switch (size) {
      case '1024x1024':
        return l10n.sizeSquare;
      case '1920x1080':
        return l10n.sizeLandscape;
      case '1080x1920':
        return l10n.sizePortrait;
      default:
        return size;
    }
  }
}
