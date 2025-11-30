import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import 'admin_scaffold.dart';

/// Dashboard Home Screen - Overview metrics and stats
class DashboardHomeScreen extends ConsumerStatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  ConsumerState<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
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

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);

    try {
      // Get total users
      final usersSnapshot = await _firestore.collection('users').get();
      _totalUsers = usersSnapshot.docs.length;

      // Get videos generated today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      int totalVideosToday = 0;
      int activeGenerations = 0;
      int totalCredits = 0;
      int successfulGenerations = 0;
      int totalGenerations = 0;

      for (var userDoc in usersSnapshot.docs) {
        // Get credits
        final creditsDoc = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('data')
            .doc('credits')
            .get();

        if (creditsDoc.exists) {
          totalCredits += (creditsDoc.data()?['credits'] as int? ?? 0);
        }

        // Get creations
        final creationsSnapshot = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('creations')
            .get();

        for (var creation in creationsSnapshot.docs) {
          final data = creation.data();
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
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
        }
      }

      _totalVideosToday = totalVideosToday;
      _activeGenerations = activeGenerations;
      _averageCredits = _totalUsers > 0 ? (totalCredits / _totalUsers).round() : 0;
      _successRate = totalGenerations > 0
          ? (successfulGenerations / totalGenerations * 100)
          : 0.0;

      // TODO: Calculate revenue from transactions collection when implemented
      _totalRevenue = 0.0;

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading metrics: $e');
      setState(() => _isLoading = false);
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                // TODO: Navigate to users
              },
              isDark: isDark,
            ),
            _buildActionButton(
              icon: Icons.video_library_rounded,
              label: 'View Content',
              onPressed: () {
                // TODO: Navigate to content
              },
              isDark: isDark,
            ),
            _buildActionButton(
              icon: Icons.payment_rounded,
              label: 'View Payments',
              onPressed: () {
                // TODO: Navigate to payments
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
}
