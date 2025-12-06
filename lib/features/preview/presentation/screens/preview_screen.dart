import 'dart:ui';
import 'dart:async';
import 'dart:io'; // Added for File support

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../core/providers/credits_provider.dart';
import '../../../creation/presentation/providers/creation_provider.dart';
import '../../../creation/domain/models/creation_config.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? prompt;
  final bool isImage;

  const PreviewScreen({
    super.key,
    this.videoUrl,
    this.thumbnailUrl,
    this.prompt,
    this.isImage = false,
  });

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isPlaying = true;
  bool _isDownloading = false;
  bool _areControlsVisible = true;
  Timer? _hideTimer;
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsOpacity;
  late AnimationController _titleAnimationController;
  // Animation<double>? _titleOpacity; // Removed as per instruction

  @override
  void initState() {
    super.initState();

    if (widget.videoUrl != null && !widget.isImage) {
      _initializePlayer();
    }

    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initial title animation setup (opacity) - unused but kept for controller init structure
    // _titleOpacity logic removed per previous refactor

    _controlsAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);

    _controlsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _controlsAnimationController, curve: Curves.easeInOut));

    _controlsAnimationController.forward();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying && !widget.isImage) {
        setState(() => _areControlsVisible = false);
        _controlsAnimationController.reverse();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _areControlsVisible = !_areControlsVisible;
      if (_areControlsVisible) {
        _controlsAnimationController.forward();
        _startHideTimer();
      } else {
        _controlsAnimationController.reverse();
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
        showControls: true, // Enable standard controls
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(25),
              child: Icon(
                icon,
                color: onTap == null
                    ? AppColors.textSecondary.withOpacity(0.5)
                    : AppColors.primaryPurple,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _titleAnimationController.dispose();
    _controlsAnimationController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  bool _isLooping = true;

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _videoPlayerController?.pause();
      } else {
        _videoPlayerController?.play();
      }
    });
  }

  void _toggleSpeed() {
    if (_videoPlayerController == null) return;
    double currentSpeed = _videoPlayerController!.value.playbackSpeed;
    double newSpeed;
    if (currentSpeed == 1.0)
      newSpeed = 1.5;
    else if (currentSpeed == 1.5)
      newSpeed = 2.0;
    else if (currentSpeed == 2.0)
      newSpeed = 0.5;
    else
      newSpeed = 1.0;

    _videoPlayerController!.setPlaybackSpeed(newSpeed);
    setState(() {}); // Update UI
  }

  void _toggleLoop() {
    if (_videoPlayerController == null) return;
    setState(() {
      _isLooping = !_isLooping;
      _videoPlayerController!.setLooping(_isLooping);
    });
  }

  Future<void> _handleDownload() async {
    if (widget.videoUrl == null || _isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      final isNetwork = widget.videoUrl!.startsWith('http');
      String filePath;

      if (isNetwork) {
        // Download the file to temp directory first
        final file = await FileUtils.downloadFile(widget.videoUrl!);
        if (file == null) throw Exception("Failed to download file");
        filePath = file.path;
      } else {
        // Already a local file
        filePath = widget.videoUrl!;
      }

      // Save to gallery
      final success = await FileUtils.saveToGallery(
        filePath,
        isVideo: !widget.isImage,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? l10n.savedToPhotos
                : l10n.failedToSave),
            backgroundColor: success ? AppColors.primaryPurple : Colors.red,
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.shareFailed(e.toString())),
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

  void _showPromptInspector() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primaryPurple),
                const SizedBox(width: 8),
                Text(
                  l10n.promptDetails,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SelectableText(
                widget.prompt ?? l10n.noPromptAvailable,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _handleRemix(); // Reuse remix logic
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.tryAgainWithPrompt),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRemix() {
    if (widget.prompt == null || widget.prompt!.isEmpty) {
      // No prompt available, just go to home
      context.go('/home');
      return;
    }

    final l10n = AppLocalizations.of(context)!;

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
                widget.isImage ? l10n.generateNewContent : l10n.generateNewVideo,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.chooseVariation,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Option 1: Use Same Prompt
              _buildDialogButton(
                label: l10n.useSamePrompt,
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
                label: l10n.enhancePrompt,
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
                label: l10n.newPrompt,
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
      final l10n = AppLocalizations.of(context)!;
      final enhancements = [
        l10n.enhanceCinematic,
        l10n.enhance4K,
        l10n.enhanceMusic,
        l10n.enhanceDynamic,
        l10n.enhanceHollywood,
        l10n.enhancePremium,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.isImage ? l10n.imagePreview : l10n.videoPreviewTitle,
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => context.go('/my-creations'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: AppColors.textPrimary),
            onPressed: _handleShare,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Area
            Container(
              color: Colors.black,
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: widget.isImage && widget.videoUrl != null
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          final isNetwork =
                              widget.videoUrl!.startsWith('http') ||
                                  widget.videoUrl!.startsWith('https');
                          return Image(
                            image: isNetwork
                                ? NetworkImage(widget.videoUrl!)
                                : FileImage(File(widget.videoUrl!))
                                    as ImageProvider,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.primaryPurple),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: Colors.white, size: 64),
                              );
                            },
                          );
                        },
                      )
                    : _chewieController != null
                        ? Chewie(controller: _chewieController!)
                        : const SizedBox(),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: _isDownloading
                        ? Icons.downloading_rounded
                        : Icons.download_rounded,
                    label: l10n.saveToPhotos,
                    onTap: _isDownloading ? null : _handleDownload,
                  ),
                  _buildActionButton(
                    icon: Icons.refresh_rounded,
                    label: l10n.remix,
                    onTap: _handleRemix,
                  ),
                  if (!widget.isImage) ...[
                    _buildActionButton(
                      icon: _isLooping
                          ? Icons.repeat_one_rounded
                          : Icons.repeat_rounded,
                      label: _isLooping ? l10n.loop : l10n.noLoop,
                      onTap: _toggleLoop,
                    ),
                    _buildActionButton(
                      icon: Icons.speed_rounded,
                      label:
                          '${_videoPlayerController?.value.playbackSpeed ?? 1}x',
                      onTap: _toggleSpeed,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Prompt Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.prompt,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.prompt ?? l10n.noPromptAvailable,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
