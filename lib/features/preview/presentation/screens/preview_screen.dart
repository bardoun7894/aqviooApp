import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final String? videoUrl;
  final String? thumbnailUrl;

  const PreviewScreen({
    super.key,
    this.videoUrl,
    this.thumbnailUrl,
  });

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isPlaying = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null) {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl!),
    );
    await _videoPlayerController!.initialize();

    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        showControls: false,
        placeholder: widget.thumbnailUrl != null
            ? Center(
                child: Image.network(
                  widget.thumbnailUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(),
                ),
              )
            : null,
      );
    });

    // Listen to playback state changes
    _videoPlayerController!.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _videoPlayerController!.value.isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _videoPlayerController?.pause();
      } else {
        _videoPlayerController?.play();
      }
    });
  }

  Future<void> _handleDownload() async {
    if (widget.videoUrl == null || _isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      // Download the file to temp directory
      await FileUtils.downloadFile(widget.videoUrl!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Video downloaded to temp folder!\nNote: Gallery save requires additional permissions.'),
            backgroundColor: AppColors.primaryPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _handleShare() async {
    if (widget.videoUrl == null) return;

    try {
      await FileUtils.shareVideo(widget.videoUrl!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Video Preview Area
          if (_chewieController != null)
            Positioned.fill(child: Chewie(controller: _chewieController!))
          else
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFA855F7),
                      Color(0xFF8B5CF6),
                      Color(0xFF6366F1),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGlassButton(
                      icon: Icons.close,
                      onTap: () => context.pop(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Text(
                            'Preview',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF1F2937),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ),
                    _buildGlassButton(
                      icon: Icons.ios_share,
                      onTap: _handleShare,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Control Bar
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Timeline/Progress
                      Row(
                        children: [
                          Text(
                            _videoPlayerController != null
                                ? _formatDuration(
                                    _videoPlayerController!.value.position,
                                  )
                                : '0:00',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTapDown: (details) {
                                if (_videoPlayerController == null) return;
                                final box =
                                    context.findRenderObject() as RenderBox?;
                                if (box == null) return;
                                final localX = details.localPosition.dx;
                                final width = box.size.width - 100;
                                final position =
                                    (localX / width).clamp(0.0, 1.0);
                                final duration =
                                    _videoPlayerController!.value.duration;
                                _videoPlayerController!.seekTo(
                                  Duration(
                                    milliseconds:
                                        (duration.inMilliseconds * position)
                                            .toInt(),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _videoPlayerController != null &&
                                          _videoPlayerController!.value.duration
                                                  .inMilliseconds >
                                              0
                                      ? _videoPlayerController!
                                              .value.position.inMilliseconds /
                                          _videoPlayerController!
                                              .value.duration.inMilliseconds
                                      : 0.0,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.3),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryPurple,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _videoPlayerController != null
                                ? _formatDuration(
                                    _videoPlayerController!.value.duration,
                                  )
                                : '0:30',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Control Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlButton(
                            icon: _isDownloading
                                ? Icons.downloading
                                : Icons.download,
                            onTap: _isDownloading ? null : _handleDownload,
                          ),
                          _buildControlButton(
                            icon: Icons.content_cut,
                            onTap: () {
                              // Handle cut/trim
                            },
                          ),
                          // Play/Pause Button (larger)
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPurple
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          _buildControlButton(
                            icon: Icons.auto_fix_high,
                            onTap: () {
                              // Handle effects
                            },
                          ),
                          _buildControlButton(
                            icon: Icons.style,
                            onTap: () {
                              // Handle styles
                            },
                          ),
                        ],
                      ),
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

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Icon(icon, color: const Color(0xFF1F2937), size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, color: const Color(0xFF374151), size: 24),
        ),
      ),
    );
  }
}
