import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/glass_container.dart';
import '../../../../../core/widgets/neumorphic_container.dart';
import 'package:akvioo/features/creation/domain/models/creation_config.dart';
import 'package:akvioo/features/creation/presentation/providers/creation_provider.dart';

class StyleConfigurationStep extends ConsumerStatefulWidget {
  const StyleConfigurationStep({super.key});

  @override
  ConsumerState<StyleConfigurationStep> createState() =>
      _StyleConfigurationStepState();
}

class _StyleConfigurationStepState
    extends ConsumerState<StyleConfigurationStep> {
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
            // Output Type Selector
            _buildSectionHeader('Output Type'),
            const SizedBox(height: 16),
            _buildOutputTypeSelector(config.outputType, controller),

            const SizedBox(height: 32),

            // Conditional rendering based on output type
            if (config.outputType == OutputType.video) ...[
              _buildVideoConfiguration(config, controller),
            ] else ...[
              _buildImageConfiguration(config, controller),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildOutputTypeSelector(
    OutputType currentType,
    CreationController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildOutputTypeCard(
            label: 'Video',
            icon: Icons.videocam_rounded,
            isSelected: currentType == OutputType.video,
            onTap: () => controller.updateOutputType(OutputType.video),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOutputTypeCard(
            label: 'Image',
            icon: Icons.image_rounded,
            isSelected: currentType == OutputType.image,
            onTap: () => controller.updateOutputType(OutputType.image),
          ),
        ),
      ],
    );
  }

  Widget _buildOutputTypeCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        borderRadius: 16,
        depth: 3,
        isConcave: isSelected,
        intensity: 0.4,
        border: Border.all(
          color: isSelected ? AppColors.primaryPurple : AppColors.glassBorder,
          width: 1.5,
        ),
        color: isSelected
            ? AppColors.primaryPurple.withOpacity(0.05)
            : AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? AppColors.primaryPurple
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoConfiguration(
    CreationConfig config,
    CreationController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Style Selection
        _buildSectionHeader('Style'),
        const SizedBox(height: 16),
        _buildStyleSelector(
            config.videoStyle ?? VideoStyle.cinematic, controller),

        const SizedBox(height: 32),

        // Duration Selection
        _buildSectionHeader('Duration'),
        const SizedBox(height: 16),
        _buildDurationSelector(config.videoDurationSeconds ?? 10, controller),

        const SizedBox(height: 32),

        // Aspect Ratio
        _buildSectionHeader('Aspect Ratio'),
        const SizedBox(height: 16),
        _buildAspectRatioSelector(
          config.videoAspectRatio ?? 'landscape',
          controller,
        ),

        const SizedBox(height: 32),

        // Voice Settings
        _buildSectionHeader('Voice Settings'),
        const SizedBox(height: 16),
        _buildVoiceSettings(config, controller),
      ],
    );
  }

  Widget _buildImageConfiguration(
    CreationConfig config,
    CreationController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Style'),
        const SizedBox(height: 16),
        _buildImageStyleSelector(
            config.imageStyle ?? ImageStyle.realistic, controller),
        const SizedBox(height: 32),
        _buildSectionHeader('Size'),
        const SizedBox(height: 16),
        _buildImageSizeSelector(config.imageSize ?? '1024x1024', controller),
      ],
    );
  }

  Widget _buildStyleSelector(
      VideoStyle currentStyle, CreationController controller) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: VideoStyle.values.map((style) {
        final isSelected = currentStyle == style;
        return GestureDetector(
          onTap: () => controller.updateVideoStyle(style),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: NeumorphicContainer(
              borderRadius: 16,
              depth: 3,
              isConcave: isSelected,
              intensity: 0.4,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.glassBorder,
                width: 1.5,
              ),
              color: isSelected
                  ? AppColors.primaryPurple.withOpacity(0.05)
                  : AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                style.displayName,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryPurple
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationSelector(
      int currentDuration, CreationController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildDurationCard(
            duration: 10,
            isSelected: currentDuration == 10,
            onTap: () => controller.updateVideoDuration(10),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDurationCard(
            duration: 15,
            isSelected: currentDuration == 15,
            onTap: () => controller.updateVideoDuration(15),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationCard({
    required int duration,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        borderRadius: 16,
        depth: isSelected ? -3 : 3,
        intensity: 0.6,
        color: isSelected
            ? AppColors.primaryPurple.withOpacity(0.05)
            : AppColors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${duration}s',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              duration == 10 ? 'Fast' : 'Longer',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isSelected
                    ? AppColors.primaryPurple.withOpacity(0.7)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAspectRatioSelector(
    String currentRatio,
    CreationController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildAspectRatioCard(
            ratio: 'landscape',
            label: '16:9',
            subtitle: 'Horizontal',
            icon: Icons.crop_landscape_rounded,
            isSelected: currentRatio == 'landscape',
            onTap: () => controller.updateVideoAspectRatio('landscape'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAspectRatioCard(
            ratio: 'portrait',
            label: '9:16',
            subtitle: 'Vertical',
            icon: Icons.crop_portrait_rounded,
            isSelected: currentRatio == 'portrait',
            onTap: () => controller.updateVideoAspectRatio('portrait'),
          ),
        ),
      ],
    );
  }

  Widget _buildAspectRatioCard({
    required String ratio,
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        borderRadius: 16,
        depth: 3,
        isConcave: isSelected,
        intensity: 0.4,
        border: Border.all(
          color: isSelected ? AppColors.primaryPurple : AppColors.glassBorder,
          width: 1.5,
        ),
        color: isSelected
            ? AppColors.primaryPurple.withOpacity(0.05)
            : AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryPurple
                  : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isSelected
                    ? AppColors.primaryPurple.withOpacity(0.7)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSettings(
    CreationConfig config,
    CreationController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Gender selection
        Row(
          children: [
            Expanded(
              child: _buildVoiceGenderCard(
                gender: VoiceGender.female,
                isSelected: config.voiceGender == VoiceGender.female,
                onTap: () => controller.updateVoiceSettings(
                  gender: VoiceGender.female,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildVoiceGenderCard(
                gender: VoiceGender.male,
                isSelected: config.voiceGender == VoiceGender.male,
                onTap: () => controller.updateVoiceSettings(
                  gender: VoiceGender.male,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Dialect selection
        _buildDialectDropdown(config.voiceDialect ?? 'ar-SA', controller),
      ],
    );
  }

  Widget _buildVoiceGenderCard({
    required VoiceGender gender,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        borderRadius: 12,
        depth: 2,
        isConcave: isSelected,
        intensity: 0.4,
        border: Border.all(
          color: isSelected ? AppColors.primaryPurple : AppColors.glassBorder,
          width: 1.5,
        ),
        color: isSelected
            ? AppColors.primaryPurple.withOpacity(0.05)
            : AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              gender == VoiceGender.female
                  ? Icons.female_rounded
                  : Icons.male_rounded,
              size: 20,
              color: isSelected
                  ? AppColors.primaryPurple
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              gender == VoiceGender.female ? 'Female' : 'Male',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialectDropdown(
      String currentDialect, CreationController controller) {
    final dialects = {
      'ar-SA': '🇸🇦 Saudi',
      'ar-EG': '🇪🇬 Egyptian',
      'ar-AE': '🇦🇪 UAE',
      'ar-LB': '🇱🇧 Lebanese',
      'ar-JO': '🇯🇴 Jordanian',
      'ar-MA': '🇲🇦 Moroccan',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentDialect,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          items: dialects.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.updateVoiceSettings(dialect: value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildImageStyleSelector(
      ImageStyle currentStyle, CreationController controller) {
    return Row(
      children: ImageStyle.values.map((style) {
        final isSelected = currentStyle == style;
        return Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: GestureDetector(
              onTap: () => controller.updateImageStyle(style),
              child: NeumorphicContainer(
                borderRadius: 12,
                depth: 2,
                isConcave: isSelected,
                intensity: 0.4,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryPurple
                      : AppColors.glassBorder,
                  width: 1.5,
                ),
                color: isSelected
                    ? AppColors.primaryPurple.withOpacity(0.05)
                    : AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  style.displayName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryPurple
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageSizeSelector(
      String currentSize, CreationController controller) {
    final sizes = {
      '1024x1024': 'Square',
      '1920x1080': 'Landscape',
      '1080x1920': 'Portrait',
    };

    return Column(
      children: sizes.entries.map((entry) {
        final isSelected = currentSize == entry.key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => controller.updateImageSize(entry.key),
            child: NeumorphicContainer(
              borderRadius: 12,
              depth: 2,
              isConcave: isSelected,
              intensity: 0.4,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.glassBorder,
                width: 1.5,
              ),
              color: isSelected
                  ? AppColors.primaryPurple.withOpacity(0.05)
                  : AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.value,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryPurple
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    entry.key,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.primaryPurple.withOpacity(0.7)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
