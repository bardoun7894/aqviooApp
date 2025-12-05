import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../dashboard/screens/admin_scaffold.dart';

/// Users List Screen - Manage all app users
class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _creditsFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      // Use collectionGroup to find all users via their creations
      // (handles phantom documents that have subcollections but no parent doc)
      final allCreationsSnapshot =
          await _firestore.collectionGroup('creations').get();

      // Extract unique user IDs from creations paths
      Set<String> userIds = {};
      for (var doc in allCreationsSnapshot.docs) {
        final pathParts = doc.reference.path.split('/');
        if (pathParts.length >= 2 && pathParts[0] == 'users') {
          userIds.add(pathParts[1]);
        }
      }

      // Also check users collection for any with actual documents
      final usersSnapshot = await _firestore.collection('users').get();
      for (var doc in usersSnapshot.docs) {
        userIds.add(doc.id);
      }

      debugPrint('Found ${userIds.length} unique users');

      final List<Map<String, dynamic>> users = [];

      for (var userId in userIds) {
        // Try to get user document data (may not exist for phantom users)
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userData =
            userDoc.exists ? userDoc.data() ?? {} : <String, dynamic>{};

        // Get credits
        final creditsDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('data')
            .doc('credits')
            .get();

        final credits = creditsDoc.exists
            ? (creditsDoc.data()?['credits'] as int? ?? 0)
            : 0;

        // Get last active (from creations) - don't use orderBy since createdAt is string
        DateTime? lastActive;
        final creationsSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('creations')
            .get();

        // Find the most recent creation manually
        for (var creation in creationsSnapshot.docs) {
          final data = creation.data();
          DateTime? createdAt;
          if (data['createdAt'] is Timestamp) {
            createdAt = (data['createdAt'] as Timestamp).toDate();
          } else if (data['createdAt'] is String) {
            try {
              createdAt = DateTime.parse(data['createdAt']);
            } catch (_) {}
          }
          if (createdAt != null &&
              (lastActive == null || createdAt.isAfter(lastActive))) {
            lastActive = createdAt;
          }
        }

        // Parse user createdAt
        DateTime? userCreatedAt;
        if (userData['createdAt'] is Timestamp) {
          userCreatedAt = (userData['createdAt'] as Timestamp).toDate();
        }

        users.add({
          'id': userId,
          'email': userData['email'] ?? 'N/A',
          'displayName':
              userData['displayName'] ?? 'User ${userId.substring(0, 6)}',
          'phoneNumber': userData['phoneNumber'] ?? 'N/A',
          'credits': credits,
          'lastActive': lastActive ?? userCreatedAt,
          'status': userData['status'] ?? 'active',
          'bannedAt': userData['bannedAt'],
          'bannedReason': userData['bannedReason'],
          'creationsCount': creationsSnapshot.docs.length,
        });
      }

      // Sort users by lastActive (most recent first)
      users.sort((a, b) {
        final aDate = a['lastActive'] as DateTime? ?? DateTime(2000);
        final bDate = b['lastActive'] as DateTime? ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading users: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          user['email']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          user['displayName']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus =
          _statusFilter == 'all' || user['status'] == _statusFilter;

      // Credits filter
      bool matchesCredits = true;
      if (_creditsFilter == 'low') {
        matchesCredits = user['credits'] < 10;
      } else if (_creditsFilter == 'medium') {
        matchesCredits = user['credits'] >= 10 && user['credits'] < 50;
      } else if (_creditsFilter == 'high') {
        matchesCredits = user['credits'] >= 50;
      }

      return matchesSearch && matchesStatus && matchesCredits;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    final filteredUsers = _filteredUsers;

    return AdminScaffold(
      currentRoute: '/admin/users',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(isDark),
          const SizedBox(height: 24),

          // Search and Filters
          _buildSearchAndFilters(isDark),
          const SizedBox(height: 24),

          // Users Table
          Expanded(
            child: _isLoading
                ? _buildLoadingState(isDark)
                : _buildUsersTable(filteredUsers, isDark),
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
              'User Management',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_users.length} total users',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _loadUsers,
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
              hintText: 'Search by name or email...',
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

        // Status Filter
        _buildFilterDropdown(
          label: 'Status',
          value: _statusFilter,
          items: const {
            'all': 'All Status',
            'active': 'Active',
            'banned': 'Banned',
          },
          onChanged: (value) => setState(() => _statusFilter = value!),
          isDark: isDark,
        ),

        // Credits Filter
        _buildFilterDropdown(
          label: 'Credits',
          value: _creditsFilter,
          items: const {
            'all': 'All Credits',
            'low': '< 10 Credits',
            'medium': '10-50 Credits',
            'high': '50+ Credits',
          },
          onChanged: (value) => setState(() => _creditsFilter = value!),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading users...',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable(List<Map<String, dynamic>> users, bool isDark) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: isDark ? AppColors.mediumGray : AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            isDark
                ? Colors.white.withOpacity(0.05)
                : AppColors.lightGray.withOpacity(0.5),
          ),
          dataRowMinHeight: 60,
          dataRowMaxHeight: 80,
          columns: [
            DataColumn(
              label: Text(
                'User',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Email',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Phone',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Credits',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Last Active',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
          rows: users.map((user) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            AppColors.primaryPurple.withOpacity(0.2),
                        child: Text(
                          user['displayName'][0].toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        user['displayName'],
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? AppColors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    user['email'],
                    style: GoogleFonts.outfit(
                      color: isDark
                          ? AppColors.mediumGray
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    user['phoneNumber'],
                    style: GoogleFonts.outfit(
                      color: isDark
                          ? AppColors.mediumGray
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${user['credits']}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    user['lastActive'] != null
                        ? DateFormat('MMM d, y').format(user['lastActive'])
                        : 'Never',
                    style: GoogleFonts.outfit(
                      color: isDark
                          ? AppColors.mediumGray
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primaryPurple,
                    ),
                    onPressed: () {
                      context.go('/admin/users/${user['id']}');
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
