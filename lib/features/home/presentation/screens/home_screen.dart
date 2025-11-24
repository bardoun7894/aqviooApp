import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_gradient_blob.dart';
import '../../../creation/presentation/providers/creation_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _promptController = TextEditingController();
  File? _selectedImage;
  final _picker = ImagePicker();
  int _selectedTab = 0; // 0 = Ideas, 1 = History
  int _currentStep = 0; // 0 = Idea, 1 = Style, 2 = Finalize
  String _selectedStyle = 'Cinematic';
  String _selectedDuration = '15s';
  String _selectedAspectRatio = '16:9';

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _generate() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a prompt'),
          backgroundColor: AppColors.primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    ref
        .read(creationControllerProvider.notifier)
        .generateVideo(prompt: prompt, imagePath: _selectedImage?.path);
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(creationControllerProvider);

    // Listen for state changes to navigate
    ref.listen(creationControllerProvider, (previous, next) {
      if (next.status == CreationStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.errorMessage}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      } else if (next.status == CreationStatus.generatingScript) {
        context.push('/magic-loading');
      } else if (next.status == CreationStatus.success) {
        if (GoRouter.of(context).canPop()) {
          context.pop();
        }
        context.push('/preview', extra: next.videoUrl);
      }
    });

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
                          'Aqvioo',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF18181B),
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.account_circle, size: 28),
                        color: AppColors.primaryPurple,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Step Indicators
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepIndicator('Idea', 0, _currentStep >= 0),
                      _buildStepConnector(_currentStep >= 1),
                      _buildStepIndicator('Style', 1, _currentStep >= 1),
                      _buildStepConnector(_currentStep >= 2),
                      _buildStepIndicator('Finalize', 2, _currentStep >= 2),
                    ],
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildStepContent(),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 560),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.4),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                        hintText:
                                            "Describe your video idea... e.g., 'A futuristic city with flying cars'",
                                        hintStyle: TextStyle(
                                          color: const Color(0xFF71717A)
                                              .withOpacity(0.8),
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
                                    ),

                                    const SizedBox(height: 20),

                                    // Divider
                                    Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.2),
                                    ),

                                    const SizedBox(height: 16),

                                    // Action Bar
                                    Row(
                                      children: [
                                        // Upload Button
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: _pickImage,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _selectedImage == null
                                                        ? Icons
                                                            .add_photo_alternate_outlined
                                                        : Icons.check_circle,
                                                    size: 18,
                                                    color:
                                                        AppColors.primaryPurple,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _selectedImage == null
                                                        ? 'Add Image'
                                                        : 'Image Added',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF52525B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        // Character Count or other indicator could go here
                                      ],
                                    ),

                                    // Image Preview
                                    if (_selectedImage != null) ...[
                                      const SizedBox(height: 16),
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
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
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              shape: const CircleBorder(),
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),
                                                onTap: () => setState(
                                                  () => _selectedImage = null,
                                                ),
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

                        const SizedBox(height: 24),

                        // Tabs
                        Container(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Row(
                            children: [
                              _buildTab('Ideas', 0),
                              const SizedBox(width: 32),
                              _buildTab('History', 1),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tab Content Placeholder
                        Container(
                          constraints: const BoxConstraints(maxWidth: 560),
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              _selectedTab == 0
                                  ? 'Your creative ideas will appear here'
                                  : 'Your generation history will appear here',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: const Color(0xFF71717A)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Button
                Container(
                  padding: const EdgeInsets.only(bottom: 24, top: 16, left: 16, right: 16),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => setState(() => _currentStep--),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryPurple,
                                side: BorderSide(color: AppColors.primaryPurple),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: _currentStep == 0 ? 1 : 2,
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _currentStep == 2 ? _generate : () => setState(() => _currentStep++),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: AppColors.primaryPurple.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _currentStep == 2 ? 'Generate' : 'Next',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isSelected
                      ? const Color(0xFF18181B)
                      : const Color(0xFF71717A),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF18181B) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
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

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(top: 18),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryPurple.withOpacity(0.3)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
