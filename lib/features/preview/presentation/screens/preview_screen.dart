import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/utils/file_utils.dart';
import '../providers/preview_provider.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final String videoUrl;

  const PreviewScreen({super.key, required this.videoUrl});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(previewControllerProvider.notifier)
          .initializeVideo(widget.videoUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(previewControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black, // Video background
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player
          if (state.isInitialized && state.videoController != null)
            Center(
              child: AspectRatio(
                aspectRatio: state.videoController!.value.aspectRatio,
                child: VideoPlayer(state.videoController!),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            ),

          // Style Overlay (Simulated Filter)
          _buildStyleOverlay(state.currentStyleIndex),

          // Gesture Detector for Swipe
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                // Swipe Right -> Previous
                ref.read(previewControllerProvider.notifier).previousStyle();
              } else if (details.primaryVelocity! < 0) {
                // Swipe Left -> Next
                ref.read(previewControllerProvider.notifier).nextStyle();
              }
            },
            onTap: () {
              ref.read(previewControllerProvider.notifier).togglePlayPause();
            },
            child: Container(color: Colors.transparent), // Transparent hit test
          ),

          // UI Overlays (Top Bar)
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          // Style Name Indicator
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: GlassCard(
                opacity: 0.3,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                borderRadius: 20,
                child: Text(
                  state.styles[state.currentStyleIndex],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Actions
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.save_alt, "Save", () async {
                  final success = await FileUtils.saveVideoToGallery(
                    widget.videoUrl,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Saved to Gallery!' : 'Failed to save',
                      ),
                    ),
                  );
                }),
                _buildActionButton(Icons.share, "Share", () {
                  FileUtils.shareVideo(widget.videoUrl);
                }),
                _buildActionButton(
                  Icons.refresh,
                  "Remake",
                  () => context.pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleOverlay(int index) {
    // Simulate styles with color filters
    Color? filterColor;
    BlendMode blendMode = BlendMode.overlay;

    switch (index) {
      case 1: // Cinematic
        filterColor = Colors.blue.withOpacity(0.2);
        break;
      case 2: // Cyberpunk
        filterColor = Colors.purple.withOpacity(0.3);
        break;
      case 3: // Vintage
        filterColor = const Color(
          0xFF704214,
        ).withOpacity(0.3); // Sepia-like brown
        blendMode = BlendMode.color;
        break;
      case 4: // Anime
        filterColor = Colors.pink.withOpacity(0.2);
        break;
      default: // Original
        return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          color: filterColor,
          backgroundBlendMode: blendMode,
        ),
        // In a real app, we'd use BackdropFilter or ShaderMask for more complex effects
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassCard(
          opacity: 0.4,
          borderRadius: 30,
          padding: const EdgeInsets.all(12),
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
