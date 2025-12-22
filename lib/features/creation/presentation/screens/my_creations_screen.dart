import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/credits_provider.dart';
import '../../../../core/widgets/generating_skeleton_card.dart';
import '../../domain/models/creation_item.dart';
import '../providers/creation_provider.dart';
import '../../../../generated/app_localizations.dart';

class MyCreationsScreen extends ConsumerStatefulWidget {
  const MyCreationsScreen({super.key});

  @override
  ConsumerState<MyCreationsScreen> createState() => _MyCreationsScreenState();
}

class _MyCreationsScreenState extends ConsumerState<MyCreationsScreen> {
  String _selectedFilter = 'All'; // All, Videos, Images, Processing, Failed
  bool _isGridView = true;
  bool _isDescending = true; // Newest first
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(creationControllerProvider);
    final allCreations = creationState.creations;

    // Filter and Search logic
    var filteredCreations = allCreations.where((item) {
      // Type/Status filters
      bool matchesFilter = true;
      if (_selectedFilter == 'Videos') {
        matchesFilter = item.type == CreationType.video;
      } else if (_selectedFilter == 'Images') {
        matchesFilter = item.type == CreationType.image;
      } else if (_selectedFilter == 'Processing') {
        matchesFilter = item.status == CreationStatus.processing;
      } else if (_selectedFilter == 'Failed') {
        matchesFilter = item.status == CreationStatus.failed;
      }

      if (!matchesFilter) return false;

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        return item.prompt.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    // Sorting logic
    filteredCreations.sort((a, b) {
      if (_isDescending) {
        return b.createdAt.compareTo(a.createdAt);
      } else {
        return a.createdAt.compareTo(b.createdAt);
      }
    });

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

                // Search Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      style: GoogleFonts.outfit(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search prompts...',
                        hintStyle: GoogleFonts.outfit(
                          color: AppColors.textSecondary.withOpacity(0.6),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary.withOpacity(0.6),
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Filter Chips and Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Filter Chips
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildFilterChip('All', allCreations.length),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                  'Videos',
                                  allCreations
                                      .where(
                                          (c) => c.type == CreationType.video)
                                      .length),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                  'Images',
                                  allCreations
                                      .where(
                                          (c) => c.type == CreationType.image)
                                      .length),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                  'Processing',
                                  allCreations
                                      .where((c) =>
                                          c.status == CreationStatus.processing)
                                      .length),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                  'Failed',
                                  allCreations
                                      .where((c) =>
                                          c.status == CreationStatus.failed)
                                      .length),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Sort Toggle
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isDescending = !_isDescending),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            _isDescending
                                ? Icons.south_rounded
                                : Icons.north_rounded,
                            size: 18,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),
                      // View Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildViewToggleButton(
                              Icons.grid_view_rounded,
                              _isGridView,
                              () => setState(() => _isGridView = true),
                            ),
                            _buildViewToggleButton(
                              Icons.view_list_rounded,
                              !_isGridView,
                              () => setState(() => _isGridView = false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Creations List/Grid
                Expanded(
                  child: filteredCreations.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            await Future.delayed(const Duration(seconds: 1));
                          },
                          color: AppColors.primaryPurple,
                          child: _isGridView
                              ? GridView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  physics: const BouncingScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.75,
                                  ),
                                  itemCount: filteredCreations.length,
                                  itemBuilder: (context, index) {
                                    return _buildGridCard(
                                        filteredCreations[index]);
                                  },
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
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
    final hasActiveFilter = _selectedFilter != 'All' || _searchQuery.isNotEmpty;

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
                    (hasActiveFilter ? Colors.grey : AppColors.primaryPurple)
                        .withOpacity(0.2),
                    (hasActiveFilter ? Colors.grey : AppColors.primaryPurple)
                        .withOpacity(0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (hasActiveFilter
                            ? Colors.grey
                            : AppColors.primaryPurple)
                        .withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                hasActiveFilter
                    ? Icons.search_off_rounded
                    : Icons.auto_awesome_rounded,
                size: 56,
                color: (hasActiveFilter ? Colors.grey : AppColors.primaryPurple)
                    .withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              hasActiveFilter
                  ? 'No matches found'
                  : AppLocalizations.of(context)!.noCreationsYet,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasActiveFilter
                  ? 'Try adjusting your filters or search query to find what you\'re looking for.'
                  : AppLocalizations.of(context)!.emptyGalleryDescription,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Action Button
            GestureDetector(
              onTap: () {
                if (hasActiveFilter) {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedFilter = 'All';
                  });
                } else {
                  context.go('/home');
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: hasActiveFilter
                      ? LinearGradient(
                          colors: [Colors.grey.shade600, Colors.grey.shade400])
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (hasActiveFilter
                              ? Colors.grey
                              : AppColors.primaryPurple)
                          .withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasActiveFilter
                          ? Icons.filter_alt_off_rounded
                          : Icons.add_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      hasActiveFilter
                          ? 'Clear all filters'
                          : AppLocalizations.of(context)!.createYourFirst,
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

  Widget _buildFilterChip(String label, int count) {
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
      case 'Processing':
        displayLabel = 'Pending';
        break;
      case 'Failed':
        displayLabel = 'Failed';
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayLabel,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.white : AppColors.primaryPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggleButton(
      IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.primaryPurple : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildGridCard(CreationItem item) {
    // Show skeleton card for processing items
    if (item.status == CreationStatus.processing) {
      return GeneratingSkeletonCard(
        isVideo: item.type == CreationType.video,
        isCompact: true,
        prompt: item.prompt,
      );
    }
    return GridCreationCard(
      item: item,
      onDelete: () => _showDeleteDialog(item),
    );
  }

  Widget _buildCreationCard(CreationItem item) {
    // Show skeleton card for processing items (list view)
    if (item.status == CreationStatus.processing) {
      return GeneratingSkeletonListCard(
        isVideo: item.type == CreationType.video,
        prompt: item.prompt,
      );
    }
    return CreationCard(
      item: item,
      onDelete: () => _showDeleteDialog(item),
    );
  }

  void _showDeleteDialog(CreationItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          AppLocalizations.of(context)!.deleteConfirmation,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteCreationMsg,
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(creationControllerProvider.notifier)
                    .deleteCreation(item.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.contentDeleted,
                        style: GoogleFonts.outfit(),
                      ),
                      backgroundColor: AppColors.primaryPurple,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.error,
                        style: GoogleFonts.outfit(),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreationCard extends StatefulWidget {
  final CreationItem item;
  final VoidCallback? onDelete;

  const CreationCard({super.key, required this.item, this.onDelete});

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

      // Navigate to full preview screen for both video and image
      context.push(
        '/preview',
        extra: {
          'videoUrl': widget.item.url,
          'thumbnailUrl': widget.item.thumbnailUrl,
          'prompt': widget.item.prompt,
          'isImage': widget.item.type == CreationType.image,
        },
      );
    }
  }

  void _showOptionsMenu() {
    if (widget.onDelete == null) return;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red),
                ),
                title: Text(
                  l10n.delete,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                subtitle: Text(
                  l10n.deleteCreationMsg,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete?.call();
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isVideo = item.type == CreationType.video;
    final isProcessing = item.status == CreationStatus.processing;
    final isFailed = item.status == CreationStatus.failed;

    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _showOptionsMenu,
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
                    // Thumbnail / Video / Image Area
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
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Show image directly for image type
                            if (!isVideo &&
                                item.url != null &&
                                item.url!.isNotEmpty)
                              Image.network(
                                item.url!,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 48,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  );
                                },
                              ),

                            // Show thumbnail for video if available
                            if (isVideo &&
                                !_isPlayerInitialized &&
                                item.thumbnailUrl != null &&
                                item.thumbnailUrl!.isNotEmpty)
                              Image.network(
                                item.thumbnailUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(),
                              ),

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

                            // Gradient Overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.0),
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),

                            // Overlay / Status Icon for processing/failed
                            if (isProcessing || isFailed)
                              Center(
                                child: isProcessing
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Icon(
                                        Icons.error_outline,
                                        size: 64,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                              ),

                            // Play icon for video
                            if (isVideo && !isProcessing && !isFailed)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                            // Expand icon for image
                            if (!isVideo && !isProcessing && !isFailed)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.fullscreen_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
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
                              // Delete button
                              if (widget.onDelete != null) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: widget.onDelete,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
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

// Grid Card for grid view
class GridCreationCard extends StatefulWidget {
  final CreationItem item;
  final VoidCallback? onDelete;

  const GridCreationCard({super.key, required this.item, this.onDelete});

  @override
  State<GridCreationCard> createState() => _GridCreationCardState();
}

class _GridCreationCardState extends State<GridCreationCard> {
  VideoPlayerController? _videoController;
  bool _isPlayerInitialized = false;

  @override
  void initState() {
    super.initState();
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
      await _videoController!.setVolume(0);
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
    _videoController?.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.item.status == CreationStatus.success &&
        widget.item.url != null) {
      // Navigate to full preview screen for both video and image
      context.push(
        '/preview',
        extra: {
          'videoUrl': widget.item.url,
          'thumbnailUrl': widget.item.thumbnailUrl,
          'prompt': widget.item.prompt,
          'isImage': widget.item.type == CreationType.image,
        },
      );
    }
  }

  void _showOptionsMenu() {
    if (widget.onDelete == null) return;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red),
                ),
                title: Text(
                  l10n.delete,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                subtitle: Text(
                  l10n.deleteCreationMsg,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete?.call();
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isVideo = item.type == CreationType.video;
    final isImage = item.type == CreationType.image;
    final hasImageUrl = isImage && item.url != null && item.url!.isNotEmpty;

    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _showOptionsMenu,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail / Video / Image Area
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isVideo
                        ? [const Color(0xFF6B9DFF), const Color(0xFF9D6BFF)]
                        : [const Color(0xFFFF6B9D), const Color(0xFFFFA06B)],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Show image directly for image type
                      if (hasImageUrl)
                        Image.network(
                          item.url!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 32,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            );
                          },
                        ),

                      // Show thumbnail for video if available
                      if (isVideo &&
                          !_isPlayerInitialized &&
                          item.thumbnailUrl != null &&
                          item.thumbnailUrl!.isNotEmpty)
                        Image.network(
                          item.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(),
                        ),

                      // Video Player
                      if (_isPlayerInitialized && _videoController != null)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController!.value.size.width,
                            height: _videoController!.value.size.height,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),

                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.0),
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),

                      // Play icon for video
                      if (isVideo)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      // Expand icon for image
                      if (isImage)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      // Delete button (tap for delete confirmation)
                      if (widget.onDelete != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: GestureDetector(
                            onTap: widget.onDelete,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.85),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.prompt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isVideo
                              ? Icons.videocam_rounded
                              : Icons.image_rounded,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isVideo
                              ? AppLocalizations.of(context)!.video
                              : AppLocalizations.of(context)!.image,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isVideo && item.duration != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.duration!,
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
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
}
