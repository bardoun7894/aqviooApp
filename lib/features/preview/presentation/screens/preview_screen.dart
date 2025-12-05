import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../core/providers/credits_provider.dart';
import '../../../creation/presentation/providers/creation_provider.dart';
import '../../../creation/domain/models/creation_config.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? prompt;

  const PreviewScreen({
    super.key,
    this.videoUrl,
    this.thumbnailUrl,
    this.prompt,
  });

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isPlaying = true;
  bool _isDownloading = false;
  late AnimationController _titleAnimationController;
  Animation<double>? _titleOpacity;

  @override
  void initState() {
    super.initState();

    // Debug: Check if prompt is being passed
    debugPrint('PreviewScreen - Prompt received: ${widget.prompt}');

    if (widget.videoUrl != null) {
      _initializePlayer();
    }
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: Curves.easeOut,
      ),
    );
    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _titleAnimationController.forward();
      }
    });
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
    _titleAnimationController.dispose();
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

  void _handleRemix() {
    if (widget.prompt == null || widget.prompt!.isEmpty) {
      // No prompt available, just go to home
      context.go('/home');
      return;
    }

    // Show confirmation dialog with 3 options
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 48,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(height: 16),
              Text(
                'Generate New Video?',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to create a new variation',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Option 1: Use Same Prompt
              _buildDialogButton(
                label: 'Use Same Prompt',
                icon: Icons.copy_rounded,
                onTap: () {
                  Navigator.pop(context);
                  _checkCreditsAndGenerate(widget.prompt!,
                      useEnhancement: false);
                },
                isPrimary: true,
              ),
              const SizedBox(height: 12),

              // Option 2: Enhance Prompt
              _buildDialogButton(
                label: 'Enhance Prompt',
                icon: Icons.auto_fix_high_rounded,
                onTap: () {
                  Navigator.pop(context);
                  _checkCreditsAndGenerate(widget.prompt!,
                      useEnhancement: true);
                },
                isPrimary: false,
              ),
              const SizedBox(height: 12),

              // Option 3: New Prompt
              _buildDialogButton(
                label: 'New Prompt',
                icon: Icons.add_circle_outline_rounded,
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(creationControllerProvider.notifier)
                      .updatePrompt('');
                  context.go('/home');
                },
                isPrimary: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkCreditsAndGenerate(String prompt,
      {required bool useEnhancement}) async {
    final creditsController = ref.read(creditsControllerProvider.notifier);
    final creditsState = ref.read(creditsControllerProvider);

    // Check if user has enough credits for video generation
    final creditCost = 10; // Video generation cost

    if (creditsState.credits < creditCost) {
      // Show insufficient credits dialog
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            AppLocalizations.of(context)!.insufficientCredits,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .needCreditsMessage(creditCost, 'video'),
                style: GoogleFonts.outfit(),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.yourBalance(creditsState.credits),
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/payment', extra: 199.0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.buyCredits,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Deduct credits
    await creditsController.deductCreditsForGeneration(OutputType.video);

    // Set the prompt
    ref.read(creationControllerProvider.notifier).updatePrompt(prompt);

    // Add random enhancement if requested
    if (useEnhancement) {
      final enhancements = [
        'with cinematic lighting and professional color grading',
        'in stunning 4K quality with dramatic atmosphere',
        'with epic music and smooth transitions',
        'featuring dynamic camera movements and vivid colors',
        'with Hollywood-style production value',
        'in premium quality with artistic composition',
      ];
      final randomEnhancement =
          enhancements[DateTime.now().millisecond % enhancements.length];
      ref
          .read(creationControllerProvider.notifier)
          .setHiddenContext(randomEnhancement);
    }

    // Start video generation
    ref.read(creationControllerProvider.notifier).generateVideo();

    // Navigate to magic loading screen
    if (mounted) {
      context.push('/magic-loading');
    }
  }

  Widget _buildDialogButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primaryPurple : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isPrimary ? Colors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  String _truncatePrompt(String? prompt) {
    if (prompt == null || prompt.isEmpty) {
      return '';
    }
    final words = prompt.trim().split(RegExp(r'\s+'));
    if (words.length <= 3) {
      return prompt;
    }
    return '${words.take(3).join(' ')}...';
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
                      Color(0xFF0F172A), // AppColors.backgroundDark
                      Color(0xFF1E293B), // Dark slate
                      Color(0xFF334155), // Dark gray
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
                    _buildCircleButton(
                      icon: Icons.close_rounded,
                      onTap: () => context.go('/my-creations'),
                    ),
                    FadeTransition(
                      opacity: _titleOpacity ?? AlwaysStoppedAnimation(0.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.prompt != null
                              ? _truncatePrompt(widget.prompt)
                              : AppLocalizations.of(context)!.preview,
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp(context),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    _buildCircleButton(
                      icon: Icons.share_rounded,
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
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
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection
                              .ltr, // Always LTR for video timeline
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16,
                              ),
                              activeTrackColor: AppColors.primaryPurple,
                              inactiveTrackColor: Colors.grey.shade300,
                              thumbColor: AppColors.primaryPurple,
                              overlayColor:
                                  AppColors.primaryPurple.withOpacity(0.2),
                            ),
                            child: Slider(
                              value: _videoPlayerController != null &&
                                      _videoPlayerController!
                                              .value.duration.inMilliseconds >
                                          0
                                  ? (_videoPlayerController!
                                          .value.position.inMilliseconds /
                                      _videoPlayerController!
                                          .value.duration.inMilliseconds)
                                  : 0.0,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (value) {
                                if (_videoPlayerController != null) {
                                  final duration =
                                      _videoPlayerController!.value.duration;
                                  _videoPlayerController!.seekTo(
                                    Duration(
                                      milliseconds:
                                          (duration.inMilliseconds * value)
                                              .toInt(),
                                    ),
                                  );
                                }
                              },
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
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          fontFeatures: [const FontFeature.tabularFigures()],
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
                            ? Icons.downloading_rounded
                            : Icons.download_rounded,
                        onTap: _isDownloading ? null : _handleDownload,
                      ),
                      _buildControlButton(
                        icon: Icons.content_cut_rounded,
                        onTap: () {
                          // Handle cut/trim
                        },
                      ),
                      // Play/Pause Button (larger)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _togglePlayPause,
                          borderRadius: BorderRadius.circular(35),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryPurple,
                                  Color(0xFF9F7AEA),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primaryPurple.withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                      _buildControlButton(
                        icon: Icons.auto_fix_high_rounded,
                        onTap: () {
                          // Handle effects
                        },
                      ),
                      _buildControlButton(
                        icon: Icons.style_rounded,
                        onTap: _handleRemix,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Opacity(
          opacity: onTap == null ? 0.5 : 1.0,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
