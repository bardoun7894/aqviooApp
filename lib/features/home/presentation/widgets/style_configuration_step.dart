import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Output Type Selector
          _buildSectionHeader('Output Type'),
          const SizedBox(height: 12),
          _buildOutputTypeSelector(config.outputType, controller),

          const SizedBox(height: 24),

          // Conditional rendering based on output type
          if (config.outputType == OutputType.video) ...[
            _buildVideoConfiguration(config, controller),
          ] else ...[
            _buildImageConfiguration(config, controller),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF18181B),
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
            icon: Icons.videocam_outlined,
            isSelected: currentType == OutputType.video,
            onTap: () => controller.updateOutputType(OutputType.video),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOutputTypeCard(
            label: 'Image',
            icon: Icons.image_outlined,
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
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryPurple : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1F2937),
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
        const SizedBox(height: 12),
        _buildStyleSelector(
            config.videoStyle ?? VideoStyle.cinematic, controller),

        const SizedBox(height: 24),

        // Duration Selection
        _buildSectionHeader('Duration'),
        const SizedBox(height: 12),
        _buildDurationSelector(config.videoDurationSeconds ?? 10, controller),

        const SizedBox(height: 24),

        // Aspect Ratio
        _buildSectionHeader('Aspect Ratio'),
        const SizedBox(height: 12),
        _buildAspectRatioSelector(
          config.videoAspectRatio ?? 'landscape',
          controller,
        ),

        const SizedBox(height: 24),

        // Voice Settings
        _buildSectionHeader('Voice Settings'),
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
        _buildImageStyleSelector(
            config.imageStyle ?? ImageStyle.realistic, controller),
        const SizedBox(height: 24),
        _buildSectionHeader('Size'),
        const SizedBox(height: 12),
        _buildImageSizeSelector(config.imageSize ?? '1024x1024', controller),
      ],
    );
  }

  Widget _buildStyleSelector(
      VideoStyle currentStyle, CreationController controller) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: VideoStyle.values.map((style) {
        final isSelected = currentStyle == style;
        return GestureDetector(
          onTap: () => controller.updateVideoStyle(style),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryPurple : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryPurple
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            child: Text(
              style.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF52525B),
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
        const SizedBox(width: 12),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F4F6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryPurple : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              '${duration}s',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.primaryPurple
                    : const Color(0xFF18181B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              duration == 10 ? 'Fast' : 'Longer',
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? AppColors.primaryPurple.withOpacity(0.7)
                    : const Color(0xFF71717A),
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
            icon: Icons.crop_landscape,
            isSelected: currentRatio == 'landscape',
            onTap: () => controller.updateVideoAspectRatio('landscape'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAspectRatioCard(
            ratio: 'portrait',
            label: '9:16',
            subtitle: 'Vertical',
            icon: Icons.crop_portrait,
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F4F6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryPurple : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryPurple
                  : const Color(0xFF52525B),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.primaryPurple
                    : const Color(0xFF18181B),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? AppColors.primaryPurple.withOpacity(0.7)
                    : const Color(0xFF71717A),
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
            const SizedBox(width: 12),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F4F6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryPurple : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              gender == VoiceGender.female
                  ? Icons.person_outline
                  : Icons.person_outline,
              size: 18,
              color: isSelected
                  ? AppColors.primaryPurple
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Text(
              gender == VoiceGender.female ? 'Female' : 'Male',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryPurple
                    : const Color(0xFF1F2937),
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
          color: const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentDialect,
          isExpanded: true,
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
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF3F4F6) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  style.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryPurple
                        : const Color(0xFF52525B),
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
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => controller.updateImageSize(entry.key),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF3F4F6) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryPurple
                      : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryPurple
                          : const Color(0xFF18181B),
                    ),
                  ),
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.primaryPurple.withOpacity(0.7)
                          : const Color(0xFF71717A),
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
