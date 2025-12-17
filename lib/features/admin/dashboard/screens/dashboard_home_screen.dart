import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../services/payment/transaction_service.dart';
import 'admin_scaffold.dart';

/// Dashboard Home Screen - Overview metrics and stats
class DashboardHomeScreen extends ConsumerStatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  ConsumerState<DashboardHomeScreen> createState() =>
      _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends ConsumerState<DashboardHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Metrics
  int _totalUsers = 0;
  int _totalVideosToday = 0;
  int _activeGenerations = 0;
  double _totalRevenue = 0.0;
  int _averageCredits = 0;
  double _successRate = 0.0;
  bool _isLoading = true;

  // Recent data lists
  List<Map<String, dynamic>> _recentUsers = [];
  List<Map<String, dynamic>> _recentCreations = [];
  List<PaymentTransaction> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);

    try {
      debugPrint('Loading dashboard metrics...');

      // Get total users - use collection group query on creations to find all users
      // since user documents may not exist (phantom documents with only subcollections)
      debugPrint('Fetching users via creations collection group...');

      // Use collectionGroup to find all creations across all users
      final allCreationsSnapshot =
          await _firestore.collectionGroup('creations').get();
      debugPrint('Found ${allCreationsSnapshot.docs.length} total creations');

      // Extract unique user IDs from creations paths
      Set<String> userIdsFromCreations = {};
      for (var doc in allCreationsSnapshot.docs) {
        // Path is: users/{userId}/creations/{creationId}
        final pathParts = doc.reference.path.split('/');
        if (pathParts.length >= 2 && pathParts[0] == 'users') {
          userIdsFromCreations.add(pathParts[1]);
        }
      }
      debugPrint('Found ${userIdsFromCreations.length} users from creations');

      // Also try to get users collection directly (for users with actual documents)
      final usersSnapshot = await _firestore.collection('users').get();
      debugPrint('Users collection returned ${usersSnapshot.docs.length} docs');

      // Combine user IDs from both sources
      Set<String> allUserIds = {...userIdsFromCreations};
      for (var doc in usersSnapshot.docs) {
        allUserIds.add(doc.id);
      }

      debugPrint('Total unique user IDs: ${allUserIds.length}');

      // Get recent users data
      _recentUsers = [];
      List<Map<String, dynamic>> allUserData = [];

      for (var userId in allUserIds) {
        // Try to get user document data
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final data =
            userDoc.exists ? userDoc.data() ?? {} : <String, dynamic>{};

        // Get credits for each user
        final creditsDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('data')
            .doc('credits')
            .get();
        final credits = creditsDoc.exists
            ? (creditsDoc.data()?['credits'] as int? ?? 0)
            : 0;

        // Get creations count
        final creationsSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('creations')
            .get();

        allUserData.add({
          'id': userId,
          'displayName':
              data['displayName'] ?? 'User ${userId.substring(0, 6)}',
          'email': data['email'] ?? 'N/A',
          'photoURL': data['photoURL'],
          'createdAt': data['createdAt'],
          'status': data['status'] ?? 'active',
          'credits': credits,
          'creationsCount': creationsSnapshot.docs.length,
        });
      }

      _totalUsers = allUserIds.length;
      _recentUsers = allUserData.take(5).toList();
      debugPrint('Total valid users: $_totalUsers');

      // Get videos generated today - use allCreationsSnapshot we already fetched
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      int totalVideosToday = 0;
      int activeGenerations = 0;
      int totalCredits = 0;
      int successfulGenerations = 0;
      int totalGenerations = 0;

      // Calculate total credits from allUserData we already collected
      for (var userData in allUserData) {
        totalCredits += (userData['credits'] as int? ?? 0);
      }

      // Collect all creations for recent list - use allCreationsSnapshot
      List<Map<String, dynamic>> allCreations = [];

      // Build a map of userId -> userData for quick lookup
      Map<String, Map<String, dynamic>> userDataMap = {};
      for (var userData in allUserData) {
        userDataMap[userData['id']] = userData;
      }

      for (var creation in allCreationsSnapshot.docs) {
        final data = creation.data();
        // Extract userId from path: users/{userId}/creations/{creationId}
        final pathParts = creation.reference.path.split('/');
        final userId = pathParts.length >= 2 ? pathParts[1] : 'unknown';
        final userData = userDataMap[userId] ?? {};

        // Handle createdAt as either Timestamp or String
        DateTime? createdAt;
        if (data['createdAt'] is Timestamp) {
          createdAt = (data['createdAt'] as Timestamp).toDate();
        } else if (data['createdAt'] is String) {
          try {
            createdAt = DateTime.parse(data['createdAt']);
          } catch (_) {}
        }
        final status = data['status'] as String?;

        if (createdAt != null && createdAt.isAfter(startOfDay)) {
          totalVideosToday++;
        }

        if (status == 'processing') {
          activeGenerations++;
        }

        totalGenerations++;
        if (status == 'completed' || status == 'success') {
          successfulGenerations++;
        }

        // Add to all creations list
        allCreations.add({
          'id': creation.id,
          'userId': userId,
          'userName':
              userData['displayName'] ?? 'User ${userId.substring(0, 6)}',
          'userEmail': userData['email'] ?? 'N/A',
          'prompt': data['prompt'] ?? 'No prompt',
          'status': status ?? 'unknown',
          'style': data['style'],
          'aspectRatio': data['aspectRatio'],
          'duration': data['duration'],
          'thumbnailUrl': data['thumbnailUrl'],
          'videoUrl': data['url'], // Note: field is 'url' not 'videoUrl'
          'createdAt': createdAt,
        });
      }

      // Sort all creations by date and take top 5
      allCreations.sort((a, b) {
        final aDate = a['createdAt'] as DateTime? ?? DateTime(2000);
        final bDate = b['createdAt'] as DateTime? ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
      _recentCreations = allCreations.take(5).toList();

      _totalVideosToday = totalVideosToday;
      _activeGenerations = activeGenerations;
      _averageCredits =
          _totalUsers > 0 ? (totalCredits / _totalUsers).round() : 0;
      _successRate = totalGenerations > 0
          ? (successfulGenerations / totalGenerations * 100)
          : 0.0;

      // Get revenue and recent transactions
      _totalRevenue = await TransactionService().getTotalRevenue();
      _recentTransactions =
          await TransactionService().getAllTransactions(limit: 5);
      debugPrint('Total revenue: $_totalRevenue');

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading metrics: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    return AdminScaffold(
      currentRoute: '/admin/dashboard',
      child: _isLoading
          ? _buildLoadingState(isDark)
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(isDark),
                  const SizedBox(height: 24),

                  // Metrics Grid
                  _buildMetricsGrid(isDark),

                  const SizedBox(height: 24),

                  // Recent Activity Section (2 columns on wide screens)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildRecentUsersSection(isDark)),
                            const SizedBox(width: 24),
                            Expanded(
                                child: _buildRecentCreationsSection(isDark)),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildRecentUsersSection(isDark),
                            const SizedBox(height: 24),
                            _buildRecentCreationsSection(isDark),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Recent Transactions
                  _buildRecentTransactionsSection(isDark),

                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(isDark),
                ],
              ),
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
            'Loading dashboard metrics...',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
            ),
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
              'Dashboard',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Overview of key metrics and system status',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _loadMetrics,
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

  Widget _buildMetricsGrid(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 3
            : constraints.maxWidth > 768
                ? 2
                : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _buildMetricCard(
              icon: Icons.people_rounded,
              title: 'Total Users',
              value: _totalUsers.toString(),
              trend: '+0%',
              trendPositive: true,
              isDark: isDark,
              gradient: LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.darkPurple],
              ),
            ),
            _buildMetricCard(
              icon: Icons.video_library_rounded,
              title: 'Videos Today',
              value: _totalVideosToday.toString(),
              trend: 'Last 24h',
              trendPositive: true,
              isDark: isDark,
              gradient: LinearGradient(
                colors: [AppColors.accentCyan, const Color(0xFF0891B2)],
              ),
            ),
            _buildMetricCard(
              icon: Icons.sync_rounded,
              title: 'Active Generations',
              value: _activeGenerations.toString(),
              trend: 'Processing',
              trendPositive: null,
              isDark: isDark,
              gradient: LinearGradient(
                colors: [AppColors.accentPink, const Color(0xFFDB2777)],
              ),
            ),
            _buildMetricCard(
              icon: Icons.attach_money_rounded,
              title: 'Total Revenue',
              value: '${_totalRevenue.toStringAsFixed(0)} SAR',
              trend: '+0%',
              trendPositive: true,
              isDark: isDark,
              gradient: LinearGradient(
                colors: [const Color(0xFF059669), const Color(0xFF047857)],
              ),
            ),
            _buildMetricCard(
              icon: Icons.stars_rounded,
              title: 'Avg Credits/User',
              value: _averageCredits.toString(),
              trend: 'Credits',
              trendPositive: null,
              isDark: isDark,
              gradient: LinearGradient(
                colors: [AppColors.lightPurple, AppColors.primaryPurple],
              ),
            ),
            _buildMetricCard(
              icon: Icons.check_circle_rounded,
              title: 'Success Rate',
              value: '${_successRate.toStringAsFixed(1)}%',
              trend: 'Generations',
              trendPositive: _successRate > 90,
              isDark: isDark,
              gradient: LinearGradient(
                colors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String trend,
    required bool? trendPositive,
    required bool isDark,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              if (trendPositive != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (trendPositive
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626))
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        trendPositive ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: trendPositive
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: trendPositive
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              icon: Icons.person_add_rounded,
              label: 'View Users',
              onPressed: () {
                context.go('/admin/users');
              },
              isDark: isDark,
            ),
            _buildActionButton(
              icon: Icons.video_library_rounded,
              label: 'View Content',
              onPressed: () {
                context.go('/admin/content');
              },
              isDark: isDark,
            ),
            _buildActionButton(
              icon: Icons.payment_rounded,
              label: 'View Payments',
              onPressed: () {
                context.go('/admin/payments');
              },
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkGray : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : AppColors.neuShadowDark.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentUsersSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryPurple, AppColors.darkPurple],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.people_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recent Users',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go('/admin/users'),
                child: Text(
                  'View All',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_recentUsers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: isDark ? AppColors.mediumGray : AppColors.textHint,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No users yet',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.mediumGray
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentUsers.length,
              separatorBuilder: (_, __) => Divider(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.neuShadowDark.withOpacity(0.1),
                height: 24,
              ),
              itemBuilder: (context, index) {
                final user = _recentUsers[index];
                return _buildUserListItem(user, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user, bool isDark) {
    // ignore: unused_local_variable
    final createdAt = (user['createdAt'] as Timestamp?)?.toDate();
    final status = user['status'] as String? ?? 'active';
    final isBanned = status == 'banned';

    return InkWell(
      onTap: () => context.go('/admin/users/${user['id']}'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
              backgroundImage: user['photoURL'] != null
                  ? NetworkImage(user['photoURL'])
                  : null,
              child: user['photoURL'] == null
                  ? Text(
                      (user['displayName'] as String?)?.isNotEmpty == true
                          ? user['displayName'][0].toUpperCase()
                          : '?',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryPurple,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user['displayName'] ?? 'Anonymous',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.white
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isBanned)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'BANNED',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user['email'] ?? 'N/A',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.mediumGray
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars_rounded,
                        size: 14, color: AppColors.primaryPurple),
                    const SizedBox(width: 4),
                    Text(
                      '${user['credits']}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${user['creationsCount']} videos',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color:
                        isDark ? AppColors.mediumGray : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCreationsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentCyan, const Color(0xFF0891B2)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.video_library_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recent Videos',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go('/admin/content'),
                child: Text(
                  'View All',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_recentCreations.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      size: 48,
                      color: isDark ? AppColors.mediumGray : AppColors.textHint,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No videos generated yet',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.mediumGray
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentCreations.length,
              separatorBuilder: (_, __) => Divider(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.neuShadowDark.withOpacity(0.1),
                height: 24,
              ),
              itemBuilder: (context, index) {
                final creation = _recentCreations[index];
                return _buildCreationListItem(creation, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCreationListItem(Map<String, dynamic> creation, bool isDark) {
    final createdAt = creation['createdAt'] as DateTime?;
    final status = creation['status'] as String? ?? 'unknown';

    return Row(
      children: [
        // Thumbnail
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            image: creation['thumbnailUrl'] != null
                ? DecorationImage(
                    image: NetworkImage(creation['thumbnailUrl']),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: creation['thumbnailUrl'] == null
              ? Icon(Icons.video_file_rounded,
                  color: AppColors.primaryPurple, size: 24)
              : null,
        ),
        const SizedBox(width: 12),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                creation['prompt'] ?? 'No prompt',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 12,
                      color: isDark
                          ? AppColors.mediumGray
                          : AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      creation['userName'] ?? 'Anonymous',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
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
              if (createdAt != null)
                Text(
                  DateFormat('MMM d, h:mm a').format(createdAt),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.mediumGray.withOpacity(0.7)
                        : AppColors.textHint,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _getStatusColor(status),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF047857)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.payment_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recent Transactions',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go('/admin/payments'),
                child: Text(
                  'View All',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_recentTransactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: isDark ? AppColors.mediumGray : AppColors.textHint,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No transactions yet',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.mediumGray
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentTransactions.length,
              separatorBuilder: (_, __) => Divider(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.neuShadowDark.withOpacity(0.1),
                height: 24,
              ),
              itemBuilder: (context, index) {
                final transaction = _recentTransactions[index];
                return _buildTransactionListItem(transaction, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionListItem(
      PaymentTransaction transaction, bool isDark) {
    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                _getTransactionStatusColor(transaction.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getTransactionIcon(transaction.status),
            color: _getTransactionStatusColor(transaction.status),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.userName,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${transaction.credits} credits • ${transaction.paymentMethod}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color:
                      isDark ? AppColors.mediumGray : AppColors.textSecondary,
                ),
              ),
              Text(
                DateFormat('MMM d, h:mm a').format(transaction.createdAt),
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.mediumGray.withOpacity(0.7)
                      : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Amount and status
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.amount.toStringAsFixed(0)} ${transaction.currency}',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _getTransactionStatusColor(transaction.status)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                transaction.status.name.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: _getTransactionStatusColor(transaction.status),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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

  Color _getTransactionStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
      case TransactionStatus.authorized:
      case TransactionStatus.captured:
        return const Color(0xFF059669);
      case TransactionStatus.pending:
        return const Color(0xFFF59E0B);
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return const Color(0xFFDC2626);
      case TransactionStatus.refunded:
        return const Color(0xFF6366F1);
    }
  }

  IconData _getTransactionIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
      case TransactionStatus.authorized:
      case TransactionStatus.captured:
        return Icons.check_circle_rounded;
      case TransactionStatus.pending:
        return Icons.pending_rounded;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return Icons.cancel_rounded;
      case TransactionStatus.refunded:
        return Icons.replay_rounded;
    }
  }
}
