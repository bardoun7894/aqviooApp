import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../auth/providers/admin_auth_provider.dart';

/// Admin Scaffold - Reusable layout for all admin pages
class AdminScaffold extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;

  const AdminScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  ConsumerState<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends ConsumerState<AdminScaffold> {
  bool _sidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final adminState = ref.watch(adminAuthControllerProvider);
    final adminUser = adminState.adminUser;

    // Auto-collapse sidebar on mobile/tablet
    if (isMobile || isTablet) {
      _sidebarExpanded = false;
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Row(
        children: [
          // Sidebar
          if (!isMobile)
            _buildSidebar(isDark, adminUser?.displayName ?? 'Admin'),

          // Mobile Drawer
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                _buildTopBar(isDark, adminUser?.displayName ?? 'Admin'),

                // Main Content Area
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: isMobile
          ? Drawer(
              child: _buildSidebarContent(isDark, adminUser?.displayName ?? 'Admin'),
            )
          : null,
    );
  }

  Widget _buildSidebar(bool isDark, String adminName) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _sidebarExpanded ? 260 : 80,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : AppColors.neuShadowDark.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: _buildSidebarContent(isDark, adminName),
    );
  }

  Widget _buildSidebarContent(bool isDark, String adminName) {
    return Column(
      children: [
        // Logo/Header
        _buildSidebarHeader(isDark),

        const SizedBox(height: 24),

        // Navigation Items
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  route: '/admin/dashboard',
                  isDark: isDark,
                  isActive: widget.currentRoute == '/admin/dashboard',
                ),
                _buildNavItem(
                  icon: Icons.people_rounded,
                  label: 'Users',
                  route: '/admin/users',
                  isDark: isDark,
                  isActive: widget.currentRoute == '/admin/users',
                ),
                _buildNavItem(
                  icon: Icons.video_library_rounded,
                  label: 'Content',
                  route: '/admin/content',
                  isDark: isDark,
                  isActive: widget.currentRoute == '/admin/content',
                ),
                _buildNavItem(
                  icon: Icons.payment_rounded,
                  label: 'Payments',
                  route: '/admin/payments',
                  isDark: isDark,
                  isActive: widget.currentRoute == '/admin/payments',
                ),
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  route: '/admin/settings',
                  isDark: isDark,
                  isActive: widget.currentRoute == '/admin/settings',
                ),
              ],
            ),
          ),
        ),

        // User Profile / Logout
        _buildSidebarFooter(isDark, adminName),
      ],
    );
  }

  Widget _buildSidebarHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),

          if (_sidebarExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aqvioo',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Admin',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
    required bool isDark,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isActive ? AppColors.primaryGradient : null,
              color: isActive
                  ? null
                  : (isDark ? Colors.transparent : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isActive
                      ? Colors.white
                      : (isDark ? AppColors.mediumGray : AppColors.textSecondary),
                ),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : (isDark ? AppColors.mediumGray : AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter(bool isDark, String adminName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : AppColors.neuShadowDark.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Admin Profile
          if (_sidebarExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryPurple.withOpacity(0.2),
                    child: Text(
                      adminName[0].toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
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
                          adminName,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.white : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Administrator',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Logout Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ref.read(adminAuthControllerProvider.notifier).signOut();
                context.go('/admin/login');
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.neuShadowDark.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                    ),
                    if (_sidebarExpanded) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark, String adminName) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : AppColors.neuShadowDark.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Toggle Sidebar (Desktop only)
          if (MediaQuery.of(context).size.width >= 768)
            IconButton(
              icon: Icon(
                _sidebarExpanded ? Icons.menu_open : Icons.menu,
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
            ),

          const Spacer(),

          // Search Bar (Optional - for future)
          // _buildSearchBar(isDark),

          // const SizedBox(width: 16),

          // Notifications
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
            ),
            onPressed: () {
              // TODO: Show notifications
            },
          ),

          const SizedBox(width: 12),

          // Admin Profile
          InkWell(
            onTap: () {
              // TODO: Show profile menu
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryPurple.withOpacity(0.2),
                    child: Text(
                      adminName[0].toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    adminName,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
