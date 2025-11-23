import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
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
        const SnackBar(content: Text('Please enter a prompt')),
      );
      return;
    }

    ref.read(creationControllerProvider.notifier).generateVideo(
          prompt: prompt,
          imagePath: _selectedImage?.path,
        );
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(creationControllerProvider);

    // Listen for state changes to navigate or show errors
    ref.listen(creationControllerProvider, (previous, next) {
      if (next.status == CreationStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.errorMessage}')),
        );
      } else if (next.status == CreationStatus.generatingScript) {
        context.push('/magic-loading');
      } else if (next.status == CreationStatus.success) {
        // Pop the magic loading screen
        if (GoRouter.of(context).canPop()) {
           context.pop(); 
        }
        
        // Navigate to Preview (Epic 4)
        context.push('/preview', extra: next.videoUrl);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Video Generated: ${next.videoUrl}')),
        // );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Magic'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.primaryPurple),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.primaryPurple),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'What do you want to create today?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Input Card
            GlassCard(
              child: Column(
                children: [
                  TextField(
                    controller: _promptController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Describe your video idea... (e.g., A futuristic city with flying cars)',
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image, color: AppColors.primaryPurple),
                        label: Text(
                          _selectedImage == null ? 'Add Image' : 'Image Added',
                          style: const TextStyle(color: AppColors.primaryPurple),
                        ),
                      ),
                      if (_selectedImage != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => setState(() => _selectedImage = null),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _selectedImage!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 32),
            GradientButton(
              label: 'Generate Magic ✨',
              onPressed: _generate,
            ),
          ],
        ),
      ),
    );
  }


}
