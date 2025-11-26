import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/glass_container.dart';
import '../../../../../core/widgets/neumorphic_container.dart';
import 'package:akvioo/features/creation/domain/models/creation_config.dart';
import 'package:akvioo/features/creation/presentation/providers/creation_provider.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../../generated/app_localizations.dart';

class ReviewFinalizeStep extends ConsumerWidget {
  const ReviewFinalizeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _buildSection(
              title: '📝 Your Idea',
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

            const SizedBox(height: 24),

            // Settings Section
            _buildSection(
              title: '⚙️ Settings',
              child: _buildSettingsPreview(config),
              onEdit: () => controller.goToStep(1),
            ),

            const SizedBox(height: 24),

            // Cost Section
            _buildCostSection(),

            const SizedBox(height: 32),

            // Generate Button
            _buildGenerateButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required VoidCallback onEdit,
  }) {
    return NeumorphicContainer(
      borderRadius: 20,
      depth: 3,
      isConcave: true, // Concave for content sections
      intensity: 0.5,
      border: Border.all(
        color: AppColors.glassBorder,
        width: 1.5,
      ),
      color: AppColors.white.withOpacity(0.5),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryPurple,
                  textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSettingsPreview(CreationConfig config) {
    if (config.outputType == OutputType.video) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingRow('Output Type', 'Video'),
          if (config.videoStyle != null)
            _buildSettingRow('Style', config.videoStyle!.displayName),
          if (config.videoDurationSeconds != null)
            _buildSettingRow('Duration', '${config.videoDurationSeconds}s'),
          if (config.videoAspectRatio != null)
            _buildSettingRow(
              'Aspect Ratio',
              config.videoAspectRatio == 'landscape'
                  ? '16:9 (Horizontal)'
                  : '9:16 (Vertical)',
            ),
          if (config.voiceGender != null && config.voiceDialect != null)
            _buildSettingRow(
              'Voice',
              '${config.voiceGender == VoiceGender.female ? "Female" : "Male"} - ${_getDialectName(config.voiceDialect!)}',
            ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingRow('Output Type', 'Image'),
          if (config.imageStyle != null)
            _buildSettingRow('Style', config.imageStyle!.displayName),
          if (config.imageSize != null)
            _buildSettingRow('Size', _getImageSizeName(config.imageSize!)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple.withOpacity(0.1),
            AppColors.primaryPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '💰 Cost',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              Text(
                '2.99',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'ر.س',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryPurple.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        // Check if user is guest
        final isAnonymous = ref.read(authRepositoryProvider).isAnonymous;

        if (isAnonymous) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Login Required'),
              content: const Text('Please login to generate your video.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/login');
                  },
                  child: Text(AppLocalizations.of(context)!.login),
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
        elevation: 8,
        shadowColor: AppColors.primaryPurple.withOpacity(0.4),
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
            'Generate Magic',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _getDialectName(String dialectCode) {
    switch (dialectCode) {
      case 'ar-SA':
        return 'Saudi';
      case 'ar-EG':
        return 'Egyptian';
      case 'ar-AE':
        return 'UAE';
      case 'ar-LB':
        return 'Lebanese';
      case 'ar-JO':
        return 'Jordanian';
      case 'ar-MA':
        return 'Moroccan';
      default:
        return 'Arabic';
    }
  }

  String _getImageSizeName(String size) {
    switch (size) {
      case '1024x1024':
        return 'Square (1024x1024)';
      case '1920x1080':
        return 'Landscape (1920x1080)';
      case '1080x1920':
        return 'Portrait (1080x1920)';
      default:
        return size;
    }
  }
}
