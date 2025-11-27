import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/creation_item.dart';
import '../providers/creation_provider.dart';

class MyCreationsScreen extends ConsumerStatefulWidget {
  const MyCreationsScreen({super.key});

  @override
  ConsumerState<MyCreationsScreen> createState() => _MyCreationsScreenState();
}

class _MyCreationsScreenState extends ConsumerState<MyCreationsScreen> {
  String _selectedFilter = 'All'; // All, Video, Image

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(creationControllerProvider);
    final allCreations = creationState.creations;

    // Filter logic
    final filteredCreations = allCreations.where((item) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Videos') return item.type == CreationType.video;
      if (_selectedFilter == 'Images') return item.type == CreationType.image;
      return true;
    }).toList();

    return Scaffold(
      body: Container(
        color: AppColors.backgroundLight,
        child: SafeArea(
          child: Column(
            children: [
              // Top App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () => context.go('/home'),
                      color: const Color(0xFF1F2937),
                    ),
                    Expanded(
                      child: Text(
                        'My Creations',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, size: 24),
                        onPressed: () => context.go('/home'),
                        color: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Videos'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Images'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Creations List
              Expanded(
                child: filteredCreations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          // Trigger a reload/poll check if needed
                          // For now, just wait a bit as polling is automatic
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredCreations.length,
                          itemBuilder: (context, index) {
                            return _buildCreationCard(filteredCreations[index]);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_creation_outlined,
              size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No creations yet',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start creating amazing videos!',
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.glassBorder.withOpacity(0.5),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryPurple.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreationCard(CreationItem item) {
    return CreationCard(item: item);
  }
}

class CreationCard extends StatefulWidget {
  final CreationItem item;

  const CreationCard({super.key, required this.item});

  @override
  State<CreationCard> createState() => _CreationCardState();
}

class _CreationCardState extends State<CreationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  VideoPlayerController? _videoController;
  bool _isPlayerInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.item.type == CreationType.video &&
        widget.item.status == CreationStatus.success &&
        widget.item.url != null) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.item.url!),
      );
      await _videoController!.initialize();
      await _videoController!.setVolume(0); // Mute for background play
      await _videoController!.setLooping(true);
      await _videoController!.play();
      if (mounted) {
        setState(() {
          _isPlayerInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video preview: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.item.status == CreationStatus.success &&
        widget.item.url != null) {
      await _animationController.forward();
      await _animationController.reverse();

      if (!mounted) return;

      if (widget.item.type == CreationType.video) {
        context.push(
          '/preview',
          extra: {
            'videoUrl': widget.item.url,
            'thumbnailUrl': widget.item.thumbnailUrl,
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(widget.item.url!),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isVideo = item.type == CreationType.video;
    final isProcessing = item.status == CreationStatus.processing;
    final isFailed = item.status == CreationStatus.failed;

    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail / Video Area
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getGradientColors(item),
                  ),
                  image:
                      item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(item.thumbnailUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Video Player (if ready)
                      if (_isPlayerInitialized && _videoController != null)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController!.value.size.width,
                            height: _videoController!.value.size.height,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),

                      // Overlay / Status Icon
                      // Show icon if:
                      // 1. Processing
                      // 2. Failed
                      // 3. Video not yet initialized (loading)
                      // 4. It's an image
                      if (isProcessing ||
                          isFailed ||
                          (!_isPlayerInitialized && isVideo) ||
                          !isVideo)
                        Center(
                          child: isProcessing
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: 1.0 +
                                          (_animationController.value * 0.2),
                                      child: Icon(
                                        isFailed
                                            ? Icons.error_outline
                                            : (isVideo
                                                ? Icons.play_circle_outline
                                                : Icons.image_outlined),
                                        size: 64,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    );
                                  },
                                ),
                        ),

                      if (isProcessing)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Text(
                            'Generating Magic...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.prompt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          isVideo
                              ? Icons.videocam_rounded
                              : Icons.image_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${isVideo ? "Video" : "Image"} • ${item.duration ?? "Standard"}',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('MMM d, yyyy').format(item.createdAt),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                    if (isFailed && item.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${item.errorMessage}',
                        style: GoogleFonts.outfit(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(CreationItem item) {
    if (item.status == CreationStatus.failed) {
      return [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)];
    }
    if (item.status == CreationStatus.processing) {
      return [
        const Color(0xFFA076F9).withOpacity(0.8),
        const Color(0xFF82C8F7).withOpacity(0.8)
      ];
    }

    // Success gradients based on type
    if (item.type == CreationType.video) {
      return [const Color(0xFF6B9DFF), const Color(0xFF9D6BFF)];
    } else {
      return [const Color(0xFFFF6B9D), const Color(0xFFFFA06B)];
    }
  }
}
