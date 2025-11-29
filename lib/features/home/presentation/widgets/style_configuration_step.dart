import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../generated/app_localizations.dart';
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

class _StyleConfigurationStepState extends ConsumerState<StyleConfigurationStep>
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
    final l10n = AppLocalizations.of(context)!;

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
            _buildAnimatedSection(
              index: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(l10n.outputType),
                  const SizedBox(height: 16),
                  _buildOutputTypeSelector(config.outputType, controller, l10n),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Conditional rendering based on output type
            if (config.outputType == OutputType.video) ...[
              _buildVideoConfiguration(config, controller, l10n),
            ] else ...[
              _buildImageConfiguration(config, controller, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
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

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOutputTypeSelector(
    OutputType currentType,
    CreationController controller,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildOutputTypeCard(
            label: l10n.video,
            icon: Icons.videocam_rounded,
            isSelected: currentType == OutputType.video,
            onTap: () => controller.updateOutputType(OutputType.video),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOutputTypeCard(
            label: l10n.image,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? AppColors.primaryPurple : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryPurple.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.glassBorder.withOpacity(0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppColors.primaryPurple,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                letterSpacing: 0.2,
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
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Style Selection
        _buildAnimatedSection(
          index: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader(l10n.styleHeader,
                  subtitle: l10n.chooseVisualMood),
              const SizedBox(height: 16),
              _buildStyleSelector(
                  config.videoStyle ?? VideoStyle.cinematic, controller),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Duration Selection
        _buildAnimatedSection(
          index: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader(l10n.durationHeader, subtitle: l10n.selectVideoLength),
              const SizedBox(height: 16),
              _buildDurationSelector(
                  config.videoDurationSeconds ?? 10, controller, l10n),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Aspect Ratio
        _buildAnimatedSection(
          index: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader(l10n.aspectRatioHeader,
                  subtitle: l10n.chooseVideoOrientation),
              const SizedBox(height: 16),
              _buildAspectRatioSelector(
                config.videoAspectRatio ?? 'landscape',
                controller,
                l10n,
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Voice Settings
        _buildAnimatedSection(
          index: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader(l10n.voiceSettingsHeader,
                  subtitle: l10n.configureNarratorVoice),
              const SizedBox(height: 16),
              _buildVoiceSettings(config, controller, l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageConfiguration(
    CreationConfig config,
    CreationController controller,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(l10n.styleHeader),
        const SizedBox(height: 16),
        _buildImageStyleSelector(
            config.imageStyle ?? ImageStyle.realistic, controller),
        const SizedBox(height: 32),
        _buildSectionHeader(l10n.sizeHeader),
        const SizedBox(height: 16),
        _buildImageSizeSelector(config.imageSize ?? '1024x1024', controller, l10n),
      ],
    );
  }

  Widget _buildStyleSelector(
      VideoStyle currentStyle, CreationController controller) {
    final styles = VideoStyle.values;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.8,
      children: styles.map((style) {
        final isSelected = currentStyle == style;
        return GestureDetector(
          onTap: () => controller.updateVideoStyle(style),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected ? AppColors.primaryPurple : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primaryPurple.withOpacity(0.2)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: isSelected ? 12 : 6,
                  offset: Offset(0, isSelected ? 4 : 2),
                ),
              ],
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.glassBorder.withOpacity(0.5),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Center(
              child: Text(
                style.displayName,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationSelector(
      int currentDuration, CreationController controller, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildDurationCard(
            duration: 10,
            label: l10n.quick,
            isSelected: currentDuration == 10,
            onTap: () => controller.updateVideoDuration(10),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDurationCard(
            duration: 15,
            label: l10n.standard,
            isSelected: currentDuration == 15,
            onTap: () => controller.updateVideoDuration(15),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationCard({
    required int duration,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? AppColors.primaryPurple : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryPurple.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.glassBorder.withOpacity(0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${duration}s',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
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
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildAspectRatioCard(
            ratio: 'landscape',
            label: '16:9',
            subtitle: l10n.horizontal,
            icon: Icons.crop_landscape_rounded,
            isSelected: currentRatio == 'landscape',
            onTap: () => controller.updateVideoAspectRatio('landscape'),
            bestFor: l10n.bestForYouTube,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAspectRatioCard(
            ratio: 'portrait',
            label: '9:16',
            subtitle: l10n.vertical,
            icon: Icons.crop_portrait_rounded,
            isSelected: currentRatio == 'portrait',
            onTap: () => controller.updateVideoAspectRatio('portrait'),
            bestFor: l10n.bestForTikTok,
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
    required String bestFor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isSelected ? AppColors.primaryPurple : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryPurple.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 20 : 10,
              offset: Offset(0, isSelected ? 8 : 4),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.glassBorder.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primaryPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 48,
                color: isSelected ? Colors.white : AppColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isSelected
                    ? Colors.white.withOpacity(0.85)
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.15)
                    : AppColors.primaryPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bestFor,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : AppColors.primaryPurple.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
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
    AppLocalizations l10n,
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
                label: l10n.female,
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
                label: l10n.male,
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
        _buildDialectDropdown(config.voiceDialect ?? 'ar-SA', controller, l10n),
      ],
    );
  }

  Widget _buildVoiceGenderCard({
    required VoiceGender gender,
    required String label,
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
              label,
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
      String currentDialect, CreationController controller, AppLocalizations l10n) {
    final dialects = {
      'ar-SA': '🇸🇦 ${l10n.dialectSaudi}',
      'ar-EG': '🇪🇬 ${l10n.dialectEgyptian}',
      'ar-AE': '🇦🇪 ${l10n.dialectUAE}',
      'ar-LB': '🇱🇧 ${l10n.dialectLebanese}',
      'ar-JO': '🇯🇴 ${l10n.dialectJordanian}',
      'ar-MA': '🇲🇦 ${l10n.dialectMoroccan}',
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
      String currentSize, CreationController controller, AppLocalizations l10n) {
    final sizes = {
      '1024x1024': l10n.square,
      '1920x1080': l10n.landscape,
      '1080x1920': l10n.portrait,
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
