import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../dashboard/screens/admin_scaffold.dart';

/// Content Viewer Screen - View and manage all generated content
class ContentViewerScreen extends ConsumerStatefulWidget {
  const ContentViewerScreen({super.key});

  @override
  ConsumerState<ContentViewerScreen> createState() => _ContentViewerScreenState();
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
    setState(() => _isLoading = true);

    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final List<Map<String, dynamic>> allContent = [];

      for (var userDoc in usersSnapshot.docs) {
        final creationsSnapshot = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('creations')
            .orderBy('createdAt', descending: true)
            .get();

        for (var creation in creationsSnapshot.docs) {
          final data = creation.data();
          allContent.add({
            'id': creation.id,
            'userId': userDoc.id,
            'userName': userDoc.data()['displayName'] ?? 'Anonymous',
            ...data,
          });
        }
      }

      // Sort by creation date
      allContent.sort((a, b) {
        final aDate = (a['createdAt'] as Timestamp?)?.toDate();
        final bDate = (b['createdAt'] as Timestamp?)?.toDate();
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

      setState(() {
        _content = allContent;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading content: $e');
      setState(() => _isLoading = false);
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
              Icons.video_library_outline,
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
    final createdAt = (item['createdAt'] as Timestamp?)?.toDate();
    final status = item['status'] as String?;
    final type = item['outputType'] as String?;

    return Container(
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Icon(
                type == 'video'
                    ? Icons.play_circle_outline
                    : Icons.image_outlined,
                size: 48,
                color: AppColors.primaryPurple,
              ),
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
                        color: isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        createdAt != null
                            ? DateFormat('MMM d').format(createdAt)
                            : 'Unknown',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.mediumGray
                              : AppColors.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status?.toUpperCase() ?? 'UNKNOWN',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: View content
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 16),
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
