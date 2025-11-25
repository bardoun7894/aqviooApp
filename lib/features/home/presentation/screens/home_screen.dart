import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_gradient_blob.dart';
import '../../../creation/presentation/providers/creation_provider.dart';

import '../widgets/style_configuration_step.dart';
import '../widgets/review_finalize_step.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _promptController = TextEditingController();
  final _pageController = PageController();
  final _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
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
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        // Navigate to magic loading or preview
        if (next.status == CreationWizardStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.errorMessage(next.errorMessage ?? '')),
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
      body: Stack(
        children: [
          // Background gradient blobs
          Positioned(
            top: -50,
            left: -50,
            child: AnimatedGradientBlob(
              size: 288,
              colors: const [Color(0xFFA882F7), Color(0xFFDDD6FE)],
              duration: const Duration(seconds: 6),
              minOpacity: 0.3,
              maxOpacity: 0.5,
              blurRadius: 60,
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: AnimatedGradientBlob(
              size: 320,
              colors: [
                AppColors.gradientBlobBlue.withOpacity(0.4),
                AppColors.gradientBlobBlue.withOpacity(0.2),
              ],
              duration: const Duration(seconds: 7),
              minOpacity: 0.3,
              maxOpacity: 0.5,
              blurRadius: 60,
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_mosaic,
                        size: 28,
                        color: AppColors.primaryPurple,
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.appTitle,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF18181B),
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.movie_creation_outlined, size: 28),
                        color: AppColors.primaryPurple,
                        onPressed: () => context.push('/my-creations'),
                      ),
                    ],
                  ),
                ),

                // Step Indicators
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStepIndicator(AppLocalizations.of(context)!.stepIdea, 0, wizardStep >= 0),
                      ),
                      Expanded(
                        child: _buildStepIndicator(AppLocalizations.of(context)!.stepStyle, 1, wizardStep >= 1),
                      ),
                      Expanded(
                        child:
                            _buildStepIndicator(AppLocalizations.of(context)!.stepFinalize, 2, wizardStep >= 2),
                      ),
                    ],
                  ),
                ),

                // PageView with 3 steps
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildIdeaStep(), // Step 0
                      const StyleConfigurationStep(), // Step 1
                      const ReviewFinalizeStep(), // Step 2
                    ],
                  ),
                ),

                // Bottom Navigation Buttons
                _buildBottomButtons(wizardStep),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(String label, int step, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.primaryPurple : const Color(0xFF71717A),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: isActive
                ? const LinearGradient(
                    colors: [
                      AppColors.primaryPurple,
                      Color(0xFF8B5CF6),
                    ],
                  )
                : null,
            color: isActive ? null : Colors.white.withOpacity(0.5),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildIdeaStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Glassmorphic Input Card
          Container(
            constraints: const BoxConstraints(maxWidth: 560),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.6),
                  Colors.white.withOpacity(0.3),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Text Input
                      TextField(
                        controller: _promptController,
                        maxLines: 5,
                        style: const TextStyle(
                          color: Color(0xFF18181B),
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.ideaStepPlaceholder,
                          hintStyle: TextStyle(
                            color: const Color(0xFF71717A).withOpacity(0.8),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          prefixIcon: Container(
                            padding: const EdgeInsets.only(
                              right: 12,
                              bottom: 80,
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 20),

                      // Divider
                      Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.2),
                      ),

                      const SizedBox(height: 16),

                      // Upload Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _selectedImage == null
                                      ? Icons.add_photo_alternate_outlined
                                      : Icons.check_circle,
                                  size: 18,
                                  color: AppColors.primaryPurple,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedImage == null
                                      ? AppLocalizations.of(context)!.addImage
                                      : AppLocalizations.of(context)!.imageAdded,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF52525B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Image Preview
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 16),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImage!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Material(
                                color: Colors.black.withOpacity(0.6),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _removeImage,
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(int currentStep) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundLight.withOpacity(0),
            AppColors.backgroundLight,
          ],
        ),
      ),
      child: Row(
        children: [
          // Back Button
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref
                      .read(creationControllerProvider.notifier)
                      .goToPreviousStep();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryPurple,
                  side: BorderSide(color: AppColors.primaryPurple),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.buttonBack,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          if (currentStep > 0) const SizedBox(width: 12),

          // Next Button (only show for step 0 and 1)
          if (currentStep < 2)
            Expanded(
              flex: currentStep > 0 ? 2 : 1,
              child: ElevatedButton(
                onPressed: _canProceedToNextStep() ? _goToNextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor:
                      AppColors.primaryPurple.withOpacity(0.5),
                  disabledForegroundColor: Colors.white.withOpacity(0.7),
                ),
                child: Text(
                  AppLocalizations.of(context)!.buttonNext,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
