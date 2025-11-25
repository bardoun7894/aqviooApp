import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import 'package:akvioo/features/creation/domain/models/creation_config.dart';
import 'package:akvioo/features/creation/presentation/providers/creation_provider.dart';

class ReviewFinalizeStep extends ConsumerWidget {
  const ReviewFinalizeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(creationControllerProvider).config;
    final controller = ref.read(creationControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF18181B),
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                if (config.imagePath != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(config.imagePath!),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
            onEdit: () => controller.goToStep(0),
          ),

          const SizedBox(height: 16),

          // Settings Section
          _buildSection(
            title: '⚙️ Settings',
            child: _buildSettingsPreview(config),
            onEdit: () => controller.goToStep(1),
          ),

          const SizedBox(height: 16),

          // Cost Section
          _buildCostSection(),

          const SizedBox(height: 24),

          // Generate Button
          _buildGenerateButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF18181B),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF71717A),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF18181B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple.withOpacity(0.1),
            AppColors.primaryPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '💰 Cost',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF18181B),
            ),
          ),
          Row(
            children: [
              Text(
                '2.99',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'ر.س',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryPurple.withOpacity(0.7),
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
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 24),
          SizedBox(width: 8),
          Text(
            'Generate',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
