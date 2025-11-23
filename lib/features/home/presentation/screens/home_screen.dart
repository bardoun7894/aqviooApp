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
                        color: Color(0xFF18181B),
                      ),
                      Expanded(
                        child: Text(
                          'Aqvioo',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: const Color(0xFF18181B),
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.account_circle, size: 28),
                        color: const Color(0xFF18181B),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Glassmorphic Input Card
                        Container(
                          constraints: const BoxConstraints(maxWidth: 560),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.white.withOpacity(0.4),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Text Input
                                    TextField(
                                      controller: _promptController,
                                      maxLines: 5,
                                      style: const TextStyle(
                                        color: Color(0xFF52525B),
                                        fontSize: 16,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText:
                                            "Describe your video or image idea... e.g., 'A 15-second promo for a summer sale'",
                                        hintStyle: TextStyle(
                                          color: Color(0xFF71717A),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(12),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Upload Image Button
                                    SizedBox(
                                      height: 40,
                                      child: ElevatedButton.icon(
                                        onPressed: _pickImage,
                                        icon: const Icon(
                                          Icons.upload_file,
                                          size: 20,
                                        ),
                                        label: Text(
                                          _selectedImage == null
                                              ? 'Upload Image'
                                              : 'Image Selected',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white
                                              .withOpacity(0.5),
                                          foregroundColor: const Color(
                                            0xFF52525B,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            side: BorderSide(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.file(
                                              _selectedImage!,
                                              height: 150,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: IconButton(
                                              onPressed: () => setState(
                                                () => _selectedImage = null,
                                              ),
                                              icon: const Icon(Icons.close),
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.5),
                                                foregroundColor: Colors.white,
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
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: const Color(0xFF71717A)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Generate Button - Sticky
                Container(
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
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 560),
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _generate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.primaryPurple.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Generate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
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
}
