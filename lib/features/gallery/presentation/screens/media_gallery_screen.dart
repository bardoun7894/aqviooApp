import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/theme/app_colors.dart';

/// Custom gallery screen with Aqvioo design system
/// Displays saved images and videos with glassmorphic UI
class MediaGalleryScreen extends ConsumerStatefulWidget {
  const MediaGalleryScreen({super.key});

  @override
  ConsumerState<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends ConsumerState<MediaGalleryScreen>
    with SingleTickerProviderStateMixin {
  List<FileSystemEntity> _mediaFiles = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadMedia();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMedia() async {
    setState(() => _isLoading = true);

    // Local file gallery not supported on web platform
    if (kIsWeb) {
      if (mounted) {
        setState(() {
          _mediaFiles = [];
          _isLoading = false;
        });
        _animationController.forward();
      }
      return;
    }

    try {
      // Get app directory for saved media
      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${directory.path}/aqvioo_media');

      if (await mediaDir.exists()) {
        final files = mediaDir.listSync();
        if (mounted) {
          setState(() {
            _mediaFiles = files
                .where(
                  (file) =>
                      file.path.endsWith('.jpg') ||
                      file.path.endsWith('.png') ||
                      file.path.endsWith('.mp4'),
                )
                .toList();

            // Try to sort by date, but don't fail if file stats aren't accessible
            try {
              _mediaFiles.sort(
                (a, b) => File(b.path).lastModifiedSync().compareTo(
                      File(a.path).lastModifiedSync(),
                    ),
              );
            } catch (e) {
              debugPrint('Could not sort files by date: $e');
              // Files will remain in their original order
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading media: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _animationController.forward();
      }
    }
  }

  List<FileSystemEntity> get _filteredFiles {
    if (_selectedFilter == 'All') return _mediaFiles;
    if (_selectedFilter == 'Images') {
      return _mediaFiles
          .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
          .toList();
    }
    return _mediaFiles.where((f) => f.path.endsWith('.mp4')).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6E6FA), // Lavender
              Color(0xFFF2F2FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(),

              // Filter Chips
              _buildFilterChips(),

              const SizedBox(height: 16),

              // Media Grid
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _filteredFiles.isEmpty
                    ? _buildEmptyState()
                    : _buildMediaGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => context.pop(),
            color: const Color(0xFF1F2937),
          ),
          Expanded(
            child: Text(
              'Media Gallery',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: _loadMedia,
            color: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('All', Icons.collections),
          const SizedBox(width: 8),
          _buildFilterChip('Images', Icons.image),
          const SizedBox(width: 8),
          _buildFilterChip('Videos', Icons.videocam),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF52525B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : const Color(0xFF52525B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: _filteredFiles.length,
          itemBuilder: (context, index) {
            final delay = index * 0.05;
            final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  delay.clamp(0.0, 1.0),
                  (delay + 0.3).clamp(0.0, 1.0),
                  curve: Curves.easeOut,
                ),
              ),
            );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: _buildMediaCard(_filteredFiles[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMediaCard(FileSystemEntity file) {
    final isVideo = file.path.endsWith('.mp4');
    final fileName = file.path.split(Platform.pathSeparator).last;

    // Try to get file size, but don't crash if it fails
    String fileSize = '--';
    try {
      final fileStats = File(file.path).statSync();
      fileSize = (fileStats.size / 1024 / 1024).toStringAsFixed(2);
    } catch (e) {
      debugPrint('Could not get file stats for ${file.path}: $e');
    }

    return GestureDetector(
      onTap: () {
        // Navigate to preview
        if (isVideo) {
          context.push('/preview', extra: file.path);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isVideo
                        ? [const Color(0xFF6B9DFF), const Color(0xFF9D6BFF)]
                        : [const Color(0xFFA076F9), const Color(0xFF82C8F7)],
                  ),
                ),
                child: Stack(
                  children: [
                    // TODO: Add actual thumbnail using image/video thumbnail package
                    Center(
                      child: Icon(
                        isVideo ? Icons.play_circle_filled : Icons.image,
                        size: 48,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    // Type badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isVideo ? 'VIDEO' : 'IMAGE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName.length > 20
                        ? '${fileName.substring(0, 17)}...'
                        : fileName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF1F2937),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.storage,
                        size: 12,
                        color: const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$fileSize MB',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryPurple),
          const SizedBox(height: 16),
          Text(
            'Loading media...',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 60,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No media yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF1F2937),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first video to see it here',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Create Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
