import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

// Mock data model for creations
class Creation {
  final String id;
  final String title;
  final String type; // 'Video' or 'Image'
  final String duration; // e.g., '15s' or 'Square'
  final String createdDate;
  final String thumbnailUrl;

  Creation({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    required this.createdDate,
    required this.thumbnailUrl,
  });
}

class MyCreationsScreen extends ConsumerStatefulWidget {
  const MyCreationsScreen({super.key});

  @override
  ConsumerState<MyCreationsScreen> createState() => _MyCreationsScreenState();
}

class _MyCreationsScreenState extends ConsumerState<MyCreationsScreen> {
  String _selectedFilter = 'All';

  // Mock data
  final List<Creation> _creations = [
    Creation(
      id: '1',
      title: 'Summer Sale Ad',
      type: 'Video',
      duration: '15s',
      createdDate: 'Oct 26, 2023',
      thumbnailUrl: '',
    ),
    Creation(
      id: '2',
      title: 'New Product Launch',
      type: 'Image',
      duration: 'Square',
      createdDate: 'Oct 24, 2023',
      thumbnailUrl: '',
    ),
    Creation(
      id: '3',
      title: 'Autumn Collection Reel',
      type: 'Video',
      duration: '30s',
      createdDate: 'Oct 22, 2023',
      thumbnailUrl: '',
    ),
  ];

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
                      icon: const Icon(Icons.menu, size: 28),
                      onPressed: () {},
                      color: const Color(0xFF1F2937),
                    ),
                    Expanded(
                      child: Text(
                        'My Creations',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
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
                    _buildSortButton(),
                    const SizedBox(width: 8),
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _creations.length,
                  itemBuilder: (context, index) {
                    return _buildCreationCard(_creations[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sort by: Most Recent',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF52525B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more, size: 20, color: Color(0xFF71717A)),
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

  Widget _buildCreationCard(Creation creation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getGradientColors(creation.id),
              ),
            ),
            child: Center(
              child: Icon(
                creation.type == 'Video'
                    ? Icons.play_circle_outline
                    : Icons.image_outlined,
                size: 64,
                color: Colors.white.withOpacity(0.8),
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
                  creation.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF1F2937),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${creation.type} - ${creation.duration}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  'Created: ${creation.createdDate}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(Icons.share),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.delete_outline),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.more_vert),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: () {},
        color: const Color(0xFF374151),
        padding: EdgeInsets.zero,
      ),
    );
  }

  List<Color> _getGradientColors(String id) {
    switch (id) {
      case '1':
        return [const Color(0xFFFF6B9D), const Color(0xFFFFA06B)];
      case '2':
        return [const Color(0xFF6B9DFF), const Color(0xFF9D6BFF)];
      case '3':
        return [const Color(0xFF6BFFA0), const Color(0xFF6BFFFF)];
      default:
        return [const Color(0xFFA076F9), const Color(0xFF82C8F7)];
    }
  }
}
