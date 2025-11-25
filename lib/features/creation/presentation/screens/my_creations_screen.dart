import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6E6FA), // Lavender
              Color(0xFFF2F2FF), // Very light purple
            ],
          ),
        ),
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
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xFF1F2937),
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start creating amazing videos!',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple
              : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: Colors.white.withOpacity(0.8)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : const Color(0xFF52525B),
                  fontWeight: FontWeight.w500,
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
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
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
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF1F2937),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isVideo ? Icons.videocam : Icons.image,
                          size: 16,
                          color: const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isVideo ? "Video" : "Image"} • ${item.duration ?? "Standard"}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF6B7280),
                                  ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('MMM d, yyyy').format(item.createdAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF9CA3AF),
                                  ),
                        ),
                      ],
                    ),
                    if (isFailed && item.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${item.errorMessage}',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
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
