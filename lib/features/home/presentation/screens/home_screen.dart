import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../generated/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_gradient_blob.dart';
import '../../../../core/widgets/app_drawer.dart';

import '../../../../core/widgets/neumorphic_container.dart';
import '../../../creation/presentation/providers/creation_provider.dart';

import '../widgets/style_configuration_step.dart';
import '../widgets/review_finalize_step.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _promptController = TextEditingController();
  final _pageController = PageController();
  final _picker = ImagePicker();
  File? _selectedImage;
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Initialize prompt from config if exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(creationControllerProvider).config;
      if (config.prompt.isNotEmpty) {
        _promptController.text = config.prompt;
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _pageController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      ref
          .read(creationControllerProvider.notifier)
          .updateImagePath(pickedFile.path);
      setState(() {});
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    ref.read(creationControllerProvider.notifier).updateImagePath(null);
  }

  void _enhancePrompt() {
    final currentText = _promptController.text;
    if (currentText.isEmpty) return;

    // Mock AI Enhancement
    final enhancedText = "$currentText (Enhanced with AI magic ✨)";

    _promptController.text = enhancedText;
    ref.read(creationControllerProvider.notifier).updatePrompt(enhancedText);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.promptEnhanced),
        backgroundColor: AppColors.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  bool _canProceedToNextStep() {
    final config = ref.read(creationControllerProvider).config;
    final currentStep = ref.read(creationControllerProvider).wizardStep;

    switch (currentStep) {
      case 0: // Idea step
        // Check the text controller directly since config isn't updated until we click Next
        return _promptController.text.trim().isNotEmpty;
      case 1: // Style step
        return config.isValid;
      default:
        return false;
    }
  }

  void _goToNextStep() {
    if (_canProceedToNextStep()) {
      // Update prompt in config before moving forward
      if (ref.read(creationControllerProvider).wizardStep == 0) {
        ref
            .read(creationControllerProvider.notifier)
            .updatePrompt(_promptController.text.trim());
      }
      ref.read(creationControllerProvider.notifier).goToNextStep();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.promptRequired),
          backgroundColor: AppColors.primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(creationControllerProvider);
    final wizardStep = creationState.wizardStep;

    // Listen for wizard step changes to animate PageView
    ref.listen<CreationState>(
      creationControllerProvider,
      (previous, next) {
        if (previous?.wizardStep != next.wizardStep) {
          _pageController.animateToPage(
            next.wizardStep,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        }

        // Navigate to magic loading or preview
        if (next.status == CreationWizardStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .errorMessage(next.errorMessage ?? '')),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        } else if (next.status == CreationWizardStatus.generatingScript) {
          context.push('/magic-loading');
        } else if (next.status == CreationWizardStatus.success) {
          if (GoRouter.of(context).canPop()) {
            context.pop();
          }
          if (next.videoUrl != null) {
            context.push('/preview', extra: next.videoUrl);
          } else {
            // Background task started - Stay on this screen or user can minimize
            // No action needed here as MagicLoadingScreen handles the UI
          }
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Animated Background
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedGradientBlob(
              size: 400,
              colors: [
                AppColors.gradientBlobPurple.withOpacity(0.4),
                AppColors.gradientBlobPink.withOpacity(0.3),
              ],
              duration: const Duration(seconds: 8),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: AnimatedGradientBlob(
              size: 350,
              colors: [
                AppColors.gradientBlobBlue.withOpacity(0.4),
                AppColors.gradientBlobPurple.withOpacity(0.2),
              ],
              duration: const Duration(seconds: 10),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => NeumorphicContainer(
                          width: 44,
                          height: 44,
                          borderRadius: 12,
                          depth: 3,
                          intensity: 0.6,
                          child: IconButton(
                            icon: const Icon(Icons.menu_rounded),
                            color: AppColors.textPrimary,
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.appTitle,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      NeumorphicContainer(
                        width: 44,
                        height: 44,
                        borderRadius: 12,
                        depth: 3,
                        intensity: 0.6,
                        child: IconButton(
                          icon: const Icon(Icons.movie_filter_rounded),
                          color: AppColors.primaryPurple,
                          onPressed: () => context.push('/my-creations'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Step Indicators
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      _buildStepIndicator(
                          AppLocalizations.of(context)!.stepIdea,
                          0,
                          wizardStep),
                      _buildConnector(0, wizardStep),
                      _buildStepIndicator(
                          AppLocalizations.of(context)!.stepStyle,
                          1,
                          wizardStep),
                      _buildConnector(1, wizardStep),
                      _buildStepIndicator(
                          AppLocalizations.of(context)!.stepFinalize,
                          2,
                          wizardStep),
                    ],
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildIdeaStep(),
                      const StyleConfigurationStep(),
                      const ReviewFinalizeStep(),
                    ],
                  ),
                ),

                // Bottom Action Area
                _buildBottomActionArea(wizardStep),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(String label, int stepIndex, int currentStep) {
    final isActive = stepIndex <= currentStep;
    final isCurrent = stepIndex == currentStep;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive ? AppColors.primaryGradient : null,
              color: isActive ? null : AppColors.white,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primaryPurple.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
              border: isActive
                  ? null
                  : Border.all(color: AppColors.mediumGray.withOpacity(0.3)),
            ),
            child: Center(
              child: isActive
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      '${stepIndex + 1}',
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color:
                  isCurrent ? AppColors.primaryPurple : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(int stepIndex, int currentStep) {
    final isActive = stepIndex < currentStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(
            horizontal: 4, vertical: 14), // Align with circle center
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryPurple
              : AppColors.mediumGray.withOpacity(0.2),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildIdeaStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.whatToCreate,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.describeYourIdea,
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),

          // Clean Material Design Input Card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Enhance Button only
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Enhance Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _enhancePrompt,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primaryPurple.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: AppColors.primaryPurple,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.of(context)!.enhance,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  constraints:
                      const BoxConstraints(minHeight: 100), // Reduced from 150
                  child: TextField(
                    controller: _promptController,
                    maxLines: null,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context)!.ideaStepPlaceholder,
                      hintStyle: GoogleFonts.outfit(
                        color: AppColors.textHint,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 16), // Reduced from 24

                // Bottom Row: Image Upload & Character Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Image Attachment Area
                    if (_selectedImage != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImage!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 12),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.05),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryPurple.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            color: AppColors.primaryPurple,
                            size: 20,
                          ),
                        ),
                      ),

                    // Character Counter
                    Text(
                      AppLocalizations.of(context)!.charsCount(_promptController.text.length),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionArea(int currentStep) {
    if (currentStep == 2)
      return const SizedBox.shrink(); // Finalize step has its own button

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: () => ref
                    .read(creationControllerProvider.notifier)
                    .goToPreviousStep(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  AppLocalizations.of(context)!.buttonBack,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _AnimatedGradientButton(
              onPressed: _canProceedToNextStep() ? _goToNextStep : null,
              label: AppLocalizations.of(context)!.buttonNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedGradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;

  const _AnimatedGradientButton({
    required this.onPressed,
    required this.label,
  });

  @override
  State<_AnimatedGradientButton> createState() =>
      _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<_AnimatedGradientButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled && _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isEnabled
                    ? AppColors.primaryPurple
                    : AppColors.mediumGray.withOpacity(0.3),
              ),
              child: Container(
                alignment: Alignment.center,
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? Colors.white : AppColors.textHint,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (isEnabled) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
