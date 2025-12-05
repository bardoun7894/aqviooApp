import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/credits_provider.dart';
import '../../domain/models/creation_item.dart';
import '../providers/creation_provider.dart';
import '../../../../generated/app_localizations.dart';

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
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          // Ambient Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryPurple.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6B9DFF).withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Modern Header
                _buildHeader(),

                const SizedBox(height: 16),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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

                const SizedBox(height: 20),

                // Creations List
                Expanded(
                  child: filteredCreations.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            await Future.delayed(const Duration(seconds: 1));
                          },
                          color: AppColors.primaryPurple,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredCreations.length,
                            itemBuilder: (context, index) {
                              return _buildCreationCard(
                                  filteredCreations[index]);
                            },
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

  Widget _buildHeader() {
    final creditsState = ref.watch(creditsControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => context.go('/home'),
              color: AppColors.textPrimary,
              padding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(width: 16),

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.yourGallery,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ).copyWith(height: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)!.myCreations,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ).copyWith(height: 1),
                ),
              ],
            ),
          ),

          // Credits Badge
          Container(
            padding:
                const EdgeInsets.only(left: 8, right: 12, top: 6, bottom: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bolt,
                    size: 12,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${creditsState.credits}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Add Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, size: 24),
              onPressed: () => context.go('/home'),
              color: Colors.white,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon Container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryPurple.withOpacity(0.2),
                    AppColors.primaryPurple.withOpacity(0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 56,
                color: AppColors.primaryPurple.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.noCreationsYet,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.emptyGalleryDescription,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Create Button
            GestureDetector(
              onTap: () => context.go('/home'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.createYourFirst,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    String displayLabel;
    switch (label) {
      case 'All':
        displayLabel = AppLocalizations.of(context)!.all;
        break;
      case 'Videos':
        displayLabel = AppLocalizations.of(context)!.videos;
        break;
      case 'Images':
        displayLabel = AppLocalizations.of(context)!.images;
        break;
      default:
        displayLabel = label;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppColors.primaryGradient
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.5),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.4)
                : AppColors.glassBorder.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryPurple.withOpacity(0.3)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            displayLabel,
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
            'prompt': widget.item.prompt,
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
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryPurple.withOpacity(0.02),
                      Colors.transparent,
                      const Color(0xFF6B9DFF).withOpacity(0.02),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail / Video Area
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _getGradientColors(item),
                        ),
                        image: item.thumbnailUrl != null &&
                                item.thumbnailUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(item.thumbnailUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Video Player (if ready)
                            if (_isPlayerInitialized &&
                                _videoController != null)
                              FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _videoController!.value.size.width,
                                  height: _videoController!.value.size.height,
                                  child: VideoPlayer(_videoController!),
                                ),
                              ),

                            // Overlay / Status Icon
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
                                                (_animationController.value *
                                                    0.2),
                                            child: Icon(
                                              isFailed
                                                  ? Icons.error_outline
                                                  : (isVideo
                                                      ? Icons
                                                          .play_circle_outline
                                                      : Icons.image_outlined),
                                              size: 64,
                                              color:
                                                  Colors.white.withOpacity(0.9),
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
                                  AppLocalizations.of(context)!.generatingMagic,
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.prompt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isVideo
                                          ? Icons.videocam_rounded
                                          : Icons.image_rounded,
                                      size: 14,
                                      color: AppColors.primaryPurple,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isVideo
                                          ? AppLocalizations.of(context)!.video
                                          : AppLocalizations.of(context)!.image,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: AppColors.primaryPurple,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.duration ??
                                    AppLocalizations.of(context)!.standard,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                DateFormat.yMMMd(Localizations.localeOf(context)
                                        .toString())
                                    .format(item.createdAt),
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                          if (isFailed && item.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.errorMessage!,
                                      style: GoogleFonts.outfit(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
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
