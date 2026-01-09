import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../dashboard/screens/admin_scaffold.dart';

/// Content Viewer Screen - View and manage all generated content
class ContentViewerScreen extends ConsumerStatefulWidget {
  const ContentViewerScreen({super.key});

  @override
  ConsumerState<ContentViewerScreen> createState() =>
      _ContentViewerScreenState();
}

class _ContentViewerScreenState extends ConsumerState<ContentViewerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _content = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _typeFilter = 'all';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Use collectionGroup to get all creations directly
      // (handles phantom user documents that have subcollections but no parent doc)
      final allCreationsSnapshot =
          await _firestore.collectionGroup('creations').get();

      if (!mounted) return; // Check after first async operation
      debugPrint('Found ${allCreationsSnapshot.docs.length} total creations');

      final List<Map<String, dynamic>> allContent = [];

      // Cache user data to avoid repeated queries
      Map<String, Map<String, dynamic>> userCache = {};

      for (var creation in allCreationsSnapshot.docs) {
        if (!mounted) return; // Check inside loop

        final data = creation.data();

        // Extract userId from path: users/{userId}/creations/{creationId}
        final pathParts = creation.reference.path.split('/');
        final userId = pathParts.length >= 2 ? pathParts[1] : 'unknown';

        // Get user data (with caching)
        if (!userCache.containsKey(userId)) {
          final userDoc =
              await _firestore.collection('users').doc(userId).get();
          if (!mounted) return; // Check after each async operation
          userCache[userId] = userDoc.exists ? userDoc.data() ?? {} : {};
        }
        final userData = userCache[userId]!;
        final userName =
            userData['displayName'] ?? 'User ${userId.substring(0, 6)}';

        // Parse createdAt - handle both Timestamp and String
        DateTime? createdAt;
        if (data['createdAt'] is Timestamp) {
          createdAt = (data['createdAt'] as Timestamp).toDate();
        } else if (data['createdAt'] is String) {
          try {
            createdAt = DateTime.parse(data['createdAt']);
          } catch (_) {}
        }

        allContent.add({
          'id': creation.id,
          'userId': userId,
          'userName': userName,
          ...data,
          'createdAt': createdAt, // Override with parsed DateTime
        });

        // Debug: Print full creation data to see what fields exist
        debugPrint('========== Creation ${creation.id} ==========');
        debugPrint('Keys: ${data.keys.toList()}');
        debugPrint('Status: ${data['status']}');
        debugPrint('URL field: ${data['url']}');
        debugPrint('VideoUrl field: ${data['videoUrl']}');
        debugPrint('Type: ${data['type']} / OutputType: ${data['outputType']}');
        debugPrint('=============================================');
      }

      // Sort by creation date
      allContent.sort((a, b) {
        final aDate = a['createdAt'] as DateTime?;
        final bDate = b['createdAt'] as DateTime?;
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

      if (mounted) {
        setState(() {
          _content = allContent;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading content: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredContent {
    return _content.where((item) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          (item['prompt'] as String?)
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ==
              true ||
          (item['userName'] as String?)
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ==
              true;

      // Type filter
      final type = item['outputType'] as String?;
      final matchesType = _typeFilter == 'all' ||
          (_typeFilter == 'video' && type == 'video') ||
          (_typeFilter == 'image' && type == 'image');

      // Status filter
      final status = item['status'] as String?;
      final matchesStatus = _statusFilter == 'all' || status == _statusFilter;

      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  Future<void> _deleteContent(String userId, String contentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Content', style: GoogleFonts.outfit()),
        content: Text(
          'Are you sure you want to delete this content? This action cannot be undone.',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.outfit()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('creations')
          .doc(contentId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Content deleted successfully'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }

      await _loadContent();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting content: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    final filteredContent = _filteredContent;

    return AdminScaffold(
      currentRoute: '/admin/content',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(isDark),
          const SizedBox(height: 24),

          // Search and Filters
          _buildSearchAndFilters(isDark),
          const SizedBox(height: 24),

          // Content Grid
          Expanded(
            child: _isLoading
                ? _buildLoadingState(isDark)
                : _buildContentGrid(filteredContent, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Management',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_content.length} total generations',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _loadContent,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: Text(
            'Refresh',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Search
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search by prompt or user...',
              hintStyle: GoogleFonts.outfit(
                color: isDark ? AppColors.mediumGray : AppColors.textHint,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkGray : AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Type Filter
        _buildFilterDropdown(
          label: 'Type',
          value: _typeFilter,
          items: const {
            'all': 'All Types',
            'video': 'Videos',
            'image': 'Images',
          },
          onChanged: (value) => setState(() => _typeFilter = value!),
          isDark: isDark,
        ),

        // Status Filter
        _buildFilterDropdown(
          label: 'Status',
          value: _statusFilter,
          items: const {
            'all': 'All Status',
            'completed': 'Completed',
            'processing': 'Processing',
            'failed': 'Failed',
          },
          onChanged: (value) => setState(() => _statusFilter = value!),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required Map<String, String> items,
    required void Function(String?) onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: const SizedBox(),
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.white : AppColors.textPrimary,
        ),
        dropdownColor: isDark ? AppColors.darkGray : AppColors.white,
        items: items.entries.map((entry) {
          return DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
      ),
    );
  }

  Widget _buildContentGrid(List<Map<String, dynamic>> content, bool isDark) {
    if (content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: isDark ? AppColors.mediumGray : AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No content found',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: content.length,
      itemBuilder: (context, index) {
        return _buildContentCard(content[index], isDark);
      },
    );
  }

  Widget _buildContentCard(Map<String, dynamic> item, bool isDark) {
    final createdAt = item['createdAt'] as DateTime?;
    final status = item['status'] as String?;
    final type = item['outputType'] as String? ?? item['type'] as String?;

    return InkWell(
      onTap: () => _showContentPreview(item, isDark),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGray : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : AppColors.neuShadowDark.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: item['thumbnailUrl'] == null
                  ? Center(
                      child: Icon(
                        type == 'video'
                            ? Icons.play_circle_outline
                            : Icons.image_outlined,
                        size: 48,
                        color: AppColors.primaryPurple,
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.network(
                            item['thumbnailUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.black.withOpacity(0.1),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 24,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.7)
                                          : AppColors.textSecondary
                                              .withOpacity(0.7),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'File deleted',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      '(Expired)',
                                      style: GoogleFonts.outfit(
                                        fontSize: 8,
                                        color: isDark
                                            ? Colors.white.withOpacity(0.8)
                                            : AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        if (type == 'video')
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        // Status badge on thumbnail
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status?.toUpperCase() ?? 'UNKNOWN',
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: isDark
                              ? AppColors.mediumGray
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item['userName'],
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.mediumGray
                                  : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Prompt
                    Expanded(
                      child: Text(
                        item['prompt'] ?? 'No prompt',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? AppColors.white : AppColors.textPrimary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Metadata chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (item['style'] != null)
                          _buildSmallChip(
                              item['style'], Icons.style_outlined, isDark),
                        if (item['aspectRatio'] != null)
                          _buildSmallChip(
                              item['aspectRatio'], Icons.aspect_ratio, isDark),
                        if (item['duration'] != null)
                          _buildSmallChip('${item['duration']}s',
                              Icons.timer_outlined, isDark),
                        _buildSmallChip(
                          createdAt != null
                              ? DateFormat('MMM d').format(createdAt)
                              : 'Unknown',
                          Icons.calendar_today_outlined,
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showContentPreview(item, isDark),
                            icon:
                                const Icon(Icons.visibility_outlined, size: 16),
                            label: Text(
                              'View',
                              style: GoogleFonts.outfit(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryPurple,
                              side: BorderSide(color: AppColors.primaryPurple),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.red,
                          onPressed: () =>
                              _deleteContent(item['userId'], item['id']),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
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

  void _showContentPreview(Map<String, dynamic> item, bool isDark) {
    final type = item['outputType'] as String?;
    final videoUrl = item['url'] as String?; // Changed from 'videoUrl' to 'url'
    final thumbnailUrl = item['thumbnailUrl'] as String?;
    final prompt = item['prompt'] as String? ?? 'No prompt';
    final userName = item['userName'] as String? ?? 'Unknown';
    final createdAt = item['createdAt'] as DateTime?;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkGray : AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : AppColors.lightGray.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        type == 'video'
                            ? Icons.play_circle_outline
                            : Icons.image_outlined,
                        color: AppColors.primaryPurple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type == 'video' ? 'Video Preview' : 'Image Preview',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'By $userName',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.mediumGray
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: isDark
                          ? AppColors.mediumGray
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),

              // Content preview
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Media preview
                      if (videoUrl != null || thumbnailUrl != null)
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: type == 'video' && videoUrl != null
                                ? _VideoPreview(videoUrl: videoUrl)
                                : Image.network(
                                    thumbnailUrl ?? '',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.black,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 48,
                                            color:
                                                Colors.white.withOpacity(0.7),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'File deleted',
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            '(Expired > 2 months)',
                                            style: GoogleFonts.outfit(
                                              fontSize: 12,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),

                      // URL and Actions
                      if (videoUrl != null)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : AppColors.lightGray.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Video URL',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.mediumGray
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: SelectableText(
                                      videoUrl,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppColors.white
                                            : AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy_rounded,
                                        size: 18),
                                    tooltip: 'Copy URL',
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: videoUrl));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('URL copied to clipboard'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.open_in_new_rounded,
                                        size: 18),
                                    tooltip: 'Open in Browser',
                                    onPressed: () async {
                                      final uri = Uri.parse(videoUrl);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      // No media - only show if no video or thumbnail
                      if (videoUrl == null && thumbnailUrl == null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color:
                                      AppColors.primaryPurple.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No preview available',
                                  style: GoogleFonts.outfit(
                                    color: isDark
                                        ? AppColors.mediumGray
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Prompt
                      Text(
                        'Prompt',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.mediumGray
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : AppColors.lightGray.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SelectableText(
                          prompt,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.white
                                : AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Metadata
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildMetaChip(
                            icon: Icons.calendar_today_outlined,
                            label: createdAt != null
                                ? DateFormat('MMM d, y • h:mm a')
                                    .format(createdAt)
                                : 'Unknown date',
                            isDark: isDark,
                          ),
                          _buildMetaChip(
                            icon: type == 'video'
                                ? Icons.videocam_outlined
                                : Icons.image_outlined,
                            label: type?.toUpperCase() ?? 'UNKNOWN',
                            isDark: isDark,
                          ),
                          if (item['style'] != null)
                            _buildMetaChip(
                              icon: Icons.style_outlined,
                              label: item['style'],
                              isDark: isDark,
                            ),
                          if (item['aspectRatio'] != null)
                            _buildMetaChip(
                              icon: Icons.aspect_ratio,
                              label: item['aspectRatio'],
                              isDark: isDark,
                            ),
                          if (item['duration'] != null)
                            _buildMetaChip(
                              icon: Icons.timer_outlined,
                              label: '${item['duration']} seconds',
                              isDark: isDark,
                            ),
                          _buildMetaChip(
                            icon: _getStatusIcon(item['status']),
                            label: (item['status'] as String?)?.toUpperCase() ??
                                'UNKNOWN',
                            isDark: isDark,
                            color: _getStatusColor(item['status']),
                          ),
                        ],
                      ),

                      // User info section
                      const SizedBox(height: 20),
                      Text(
                        'Created By',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.mediumGray
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : AppColors.lightGray.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  AppColors.primaryPurple.withOpacity(0.1),
                              child: Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'User ID: ${item['userId']?.toString().substring(0, 8) ?? 'N/A'}...',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.mediumGray
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : AppColors.neuShadowDark.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (videoUrl != null)
                      OutlinedButton.icon(
                        onPressed: () {
                          // Copy URL to clipboard - simple approach
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: SelectableText(
                                'Video URL: $videoUrl',
                                style: GoogleFonts.outfit(color: Colors.white),
                              ),
                              duration: const Duration(seconds: 10),
                            ),
                          );
                        },
                        icon: const Icon(Icons.link, size: 16),
                        label: Text(
                          'Copy URL',
                          style: GoogleFonts.outfit(),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryPurple,
                        ),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required bool isDark,
    Color? color,
  }) {
    final chipColor =
        color ?? (isDark ? AppColors.mediumGray : AppColors.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color != null
            ? color.withOpacity(0.1)
            : (isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGray),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: chipColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: color != null ? FontWeight.w600 : FontWeight.w400,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'completed':
      case 'success':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.hourglass_empty;
      case 'failed':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildSmallChip(String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : AppColors.lightGray,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
      case 'success':
        return const Color(0xFF059669);
      case 'processing':
        return const Color(0xFFF59E0B);
      case 'failed':
        return const Color(0xFFDC2626);
      default:
        return AppColors.mediumGray;
    }
  }
}

class _VideoPreview extends StatefulWidget {
  final String videoUrl;

  const _VideoPreview({required this.videoUrl});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _error = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 VideoPreview: Initializing with URL: ${widget.videoUrl}');
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      debugPrint('🎬 VideoPreview: Creating VideoPlayerController...');
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      // Add error listener for async playback errors (like 404)
      _videoPlayerController.addListener(() {
        if (mounted && _videoPlayerController.value.hasError) {
          setState(() {
            _error = true;
            _isLoading = false;
            _errorMessage = 'Video file deleted or expired';
          });
        }
      });

      debugPrint('🎬 VideoPreview: Calling initialize()...');
      await _videoPlayerController.initialize();
      debugPrint('🎬 VideoPreview: Video initialized successfully!');
      debugPrint(
          '🎬 VideoPreview: Aspect ratio: ${_videoPlayerController.value.aspectRatio}');
      debugPrint(
          '🎬 VideoPreview: Duration: ${_videoPlayerController.value.duration}');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            autoPlay: true,
            looping: true,
            showControls: true,
            aspectRatio: _videoPlayerController.value.aspectRatio,
            placeholder: Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            errorBuilder: (context, errorMessage) {
              debugPrint('🎬 VideoPreview: Chewie error: $errorMessage');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          );
        });
      }
    } catch (e, stack) {
      debugPrint('🎬 VideoPreview: ERROR initializing video player: $e');
      debugPrint('🎬 VideoPreview: Stack trace: $stack');
      if (mounted) {
        setState(() {
          _error = true;
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    debugPrint('🎬 VideoPreview: Disposing...');
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            const Text('Failed to load video',
                style: TextStyle(color: Colors.white)),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(widget.videoUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open in Browser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Loading video...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    if (_chewieController != null &&
        _videoPlayerController.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    }

    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
