import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../dashboard/screens/admin_scaffold.dart';
import '../../auth/providers/admin_auth_provider.dart';
import '../../auth/models/admin_user.dart';

/// User Detail Screen - View and manage individual user
class UserDetailScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _userData;
  int _userCredits = 0;
  List<Map<String, dynamic>> _creations = [];
  bool _isLoading = true;
  AdminRole? _targetAdminRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Get user data - don't require document to exist (phantom users)
      final userDoc =
          await _firestore.collection('users').doc(widget.userId).get();
      _userData = userDoc.exists ? userDoc.data() : <String, dynamic>{};

      // Get credits - read balance field first (mobile uses this), fallback to credits
      final creditsDoc = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('data')
          .doc('credits')
          .get();

      if (creditsDoc.exists) {
        final data = creditsDoc.data();
        // Prefer balance field (double), fallback to credits (int)
        // Prefer max of balance/credits to handle sync issues (same as mobile app)
        double balanceVal = (data?['balance'] as num?)?.toDouble() ?? 0.0;
        double creditsVal = (data?['credits'] as num?)?.toDouble() ?? 0.0;
        _userCredits =
            (balanceVal > creditsVal ? balanceVal : creditsVal).floor();
      } else {
        _userCredits = 0;
      }

      // Check if user is an admin
      final adminDoc =
          await _firestore.collection('admins').doc(widget.userId).get();
      if (adminDoc.exists) {
        final adminData = adminDoc.data();
        if (adminData != null && adminData['role'] != null) {
          _targetAdminRole = AdminRole.values.firstWhere(
            (r) => r.name == adminData['role'],
            orElse: () => AdminRole.admin,
          );
        }
      } else {
        _targetAdminRole = null;
      }

      // Get creations - don't use orderBy since createdAt may be string
      final creationsSnapshot = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('creations')
          .get();

      // Parse and sort creations manually
      List<Map<String, dynamic>> creationsList = [];
      for (var doc in creationsSnapshot.docs) {
        final data = doc.data();
        // Parse createdAt
        DateTime? createdAt;
        if (data['createdAt'] is Timestamp) {
          createdAt = (data['createdAt'] as Timestamp).toDate();
        } else if (data['createdAt'] is String) {
          try {
            createdAt = DateTime.parse(data['createdAt']);
          } catch (_) {}
        }
        creationsList.add({
          'id': doc.id,
          ...data,
          'createdAt': createdAt, // Override with parsed DateTime
        });
      }

      // Sort by createdAt descending
      creationsList.sort((a, b) {
        final aDate = a['createdAt'] as DateTime?;
        final bDate = b['createdAt'] as DateTime?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      _creations = creationsList.take(10).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showCreditAdjustmentDialog(bool isDark) async {
    final amountController = TextEditingController();
    String reason = 'bonus';
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkGray : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Adjust Credits',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.textPrimary,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Balance: $_userCredits credits',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))
                ],
                style: GoogleFonts.outfit(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount (+ to add, - to subtract)',
                  labelStyle: GoogleFonts.outfit(
                    color:
                        isDark ? AppColors.mediumGray : AppColors.textSecondary,
                  ),
                  hintText: 'e.g., +10 or -5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: reason,
                onChanged: (value) => setDialogState(() => reason = value!),
                style: GoogleFonts.outfit(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
                dropdownColor: isDark ? AppColors.darkGray : AppColors.white,
                decoration: InputDecoration(
                  labelText: 'Reason',
                  labelStyle: GoogleFonts.outfit(
                    color:
                        isDark ? AppColors.mediumGray : AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'bonus', child: Text('Bonus')),
                  DropdownMenuItem(value: 'refund', child: Text('Refund')),
                  DropdownMenuItem(
                      value: 'correction', child: Text('Correction')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                style: GoogleFonts.outfit(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  labelStyle: GoogleFonts.outfit(
                    color:
                        isDark ? AppColors.mediumGray : AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = int.tryParse(amountController.text);
              if (amount == null || amount == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }

              Navigator.pop(context);
              await _adjustCredits(amount, reason, notesController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Confirm', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }

  Future<void> _adjustCredits(int amount, String reason, String notes) async {
    try {
      final newCredits = _userCredits + amount;

      if (newCredits < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot reduce credits below 0')),
        );
        return;
      }

      // Update credits - write both fields for mobile/web compatibility
      await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('data')
          .doc('credits')
          .update({
        'balance': newCredits.toDouble(),
        'credits': newCredits,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Create audit log
      final adminUser = ref.read(adminAuthControllerProvider).adminUser;
      await _firestore.collection('audit_logs').add({
        'adminId': adminUser?.id ?? 'unknown',
        'adminName': adminUser?.displayName ?? 'Unknown Admin',
        'action': 'credit_adjustment',
        'targetType': 'user',
        'targetId': widget.userId,
        'details': {
          'amount': amount,
          'previousBalance': _userCredits,
          'newBalance': newCredits,
          'reason': reason,
          'notes': notes,
        },
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Credits adjusted: ${amount > 0 ? '+' : ''}$amount'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }

      // Reload data
      await _loadUserData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    return AdminScaffold(
      currentRoute: '/admin/users',
      child: _isLoading
          ? _buildLoadingState(isDark)
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(isDark),
                  const SizedBox(height: 24),

                  // User Info Card
                  _buildUserInfoCard(isDark),
                  const SizedBox(height: 24),

                  // Admin Role Card
                  _buildAdminRoleCard(isDark),
                  const SizedBox(height: 24),

                  // Ban Status Card
                  _buildBanStatusCard(isDark),
                  const SizedBox(height: 24),

                  // Credits Card
                  _buildCreditsCard(isDark),
                  const SizedBox(height: 24),

                  // Recent Creations
                  _buildRecentCreations(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildAdminRoleCard(bool isDark) {
    // Only show for Super Admins (or those with canManageAdmins permission)
    final currentUser = ref.watch(adminAuthControllerProvider).adminUser;
    if (currentUser == null || !currentUser.permissions.canManageAdmins) {
      return const SizedBox.shrink();
    }

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
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Admin Access',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Manage this user administrative privileges.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.mediumGray : AppColors.neuShadowDark,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AdminRole?>(
                value: _targetAdminRole,
                isExpanded: true,
                dropdownColor: isDark ? AppColors.darkGray : AppColors.white,
                hint: Text(
                  'Select Role (None)',
                  style: GoogleFonts.outfit(
                    color:
                        isDark ? AppColors.mediumGray : AppColors.textSecondary,
                  ),
                ),
                items: [
                  DropdownMenuItem<AdminRole?>(
                    value: null,
                    child: Text(
                      'None (Regular User)',
                      style: GoogleFonts.outfit(
                        color: isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  ...AdminRole.values.map(
                    (role) => DropdownMenuItem<AdminRole?>(
                      value: role,
                      child: Text(
                        role.name.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color:
                              isDark ? AppColors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                onChanged: _updateAdminRole,
              ),
            ),
          ),
        ],
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

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.white : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _userData?['displayName'] ?? 'User Details',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            Text(
              'User ID: ${widget.userId.substring(0, 8)}...',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(bool isDark) {
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
          Text(
            'User Information',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Email', _userData?['email'] ?? 'N/A',
              Icons.email_outlined, isDark),
          const SizedBox(height: 12),
          _buildInfoRow('Phone', _userData?['phoneNumber'] ?? 'N/A',
              Icons.phone_outlined, isDark),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Joined',
            _userData?['createdAt'] != null
                ? DateFormat('MMM d, y')
                    .format((_userData!['createdAt'] as Timestamp).toDate())
                : 'N/A',
            Icons.calendar_today_outlined,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryPurple,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCreditsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Credit Balance',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_userCredits',
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.stars_rounded,
                size: 48,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showCreditAdjustmentDialog(isDark),
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: Text(
              'Adjust Credits',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryPurple,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCreations(bool isDark) {
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
          Text(
            'Recent Creations (${_creations.length})',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_creations.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No creations yet',
                  style: GoogleFonts.outfit(
                    color:
                        isDark ? AppColors.mediumGray : AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _creations.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final creation = _creations[index];
                return _buildCreationItem(creation, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCreationItem(Map<String, dynamic> creation, bool isDark) {
    final createdAt = creation['createdAt'] as DateTime?;
    final status = creation['status'] as String?;

    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.video_library_rounded,
            color: AppColors.primaryPurple,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                creation['prompt'] ?? 'No prompt',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                createdAt != null
                    ? DateFormat('MMM d, y • h:mm a').format(createdAt)
                    : 'Unknown date',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color:
                      isDark ? AppColors.mediumGray : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status?.toUpperCase() ?? 'UNKNOWN',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _getStatusColor(status),
            ),
          ),
        ),
      ],
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

  Widget _buildBanStatusCard(bool isDark) {
    final status = _userData?['status'] ?? 'active';
    final isBanned = status == 'banned';
    final bannedAt = _userData?['bannedAt'] as Timestamp?;
    final bannedReason = _userData?['bannedReason'] as String?;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isBanned
            ? Border.all(
                color: const Color(0xFFDC2626).withOpacity(0.5), width: 2)
            : null,
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
                  Icon(
                    isBanned
                        ? Icons.block_rounded
                        : Icons.verified_user_rounded,
                    color: isBanned
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF059669),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Account Status',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isBanned
                      ? const Color(0xFFDC2626).withOpacity(0.1)
                      : const Color(0xFF059669).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isBanned ? 'BANNED' : 'ACTIVE',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isBanned
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          if (isBanned) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bannedAt != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: isDark
                              ? AppColors.mediumGray
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Banned on: ${DateFormat('MMM d, y • h:mm a').format(bannedAt.toDate())}',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.mediumGray
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (bannedReason != null && bannedReason.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: isDark
                              ? AppColors.mediumGray
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reason: $bannedReason',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.mediumGray
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () =>
                isBanned ? _showUnbanDialog(isDark) : _showBanDialog(isDark),
            icon: Icon(
              isBanned ? Icons.check_circle_outline : Icons.block_rounded,
              size: 18,
            ),
            label: Text(
              isBanned ? 'Unban User' : 'Ban User',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isBanned ? const Color(0xFF059669) : const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBanDialog(bool isDark) async {
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkGray : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Color(0xFFDC2626)),
            const SizedBox(width: 12),
            Text(
              'Ban User',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to ban this user? They will no longer be able to access the app.',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: GoogleFonts.outfit(
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Reason for ban',
                labelStyle: GoogleFonts.outfit(
                  color:
                      isDark ? AppColors.mediumGray : AppColors.textSecondary,
                ),
                hintText: 'e.g., Violation of terms of service',
                hintStyle: GoogleFonts.outfit(
                  color: isDark
                      ? AppColors.mediumGray.withOpacity(0.5)
                      : AppColors.textHint,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _banUser(reasonController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Ban User',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _showUnbanDialog(bool isDark) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkGray : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFF059669)),
            const SizedBox(width: 12),
            Text(
              'Unban User',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to unban this user? They will regain access to the app.',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _unbanUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Unban User',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _banUser(String reason) async {
    try {
      // Update user status
      await _firestore.collection('users').doc(widget.userId).update({
        'status': 'banned',
        'bannedAt': FieldValue.serverTimestamp(),
        'bannedReason': reason.isNotEmpty ? reason : 'No reason provided',
      });

      // Create audit log
      final adminUser = ref.read(adminAuthControllerProvider).adminUser;
      await _firestore.collection('audit_logs').add({
        'adminId': adminUser?.id ?? 'unknown',
        'adminName': adminUser?.displayName ?? 'Unknown Admin',
        'action': 'user_banned',
        'targetType': 'user',
        'targetId': widget.userId,
        'details': {
          'reason': reason.isNotEmpty ? reason : 'No reason provided',
        },
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User has been banned'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }

      // Reload data
      await _loadUserData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error banning user: $e')),
        );
      }
    }
  }

  Future<void> _updateAdminRole(AdminRole? newRole) async {
    setState(() => _isLoading = true);
    try {
      if (newRole == null) {
        // Remove admin access
        await _firestore.collection('admins').doc(widget.userId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin access removed')),
          );
        }
      } else {
        // Grant/Update admin access
        final adminData = AdminUser(
          id: widget.userId,
          email: _userData?['email'] ?? '',
          displayName: _userData?['displayName'] ?? 'Admin',
          role: newRole,
          permissions: _getPermissionsForRole(newRole),
          createdAt: DateTime.now(),
        ).toMap();

        // Use set with merge true to preserve fields if exists, but we want to overwrite role/permissions
        await _firestore.collection('admins').doc(widget.userId).set(
              adminData,
              SetOptions(merge: true),
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Role updated to ${newRole.name}')),
          );
        }
      }

      setState(() => _targetAdminRole = newRole);
    } catch (e) {
      debugPrint('Error updating admin role: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating role: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  AdminPermissions _getPermissionsForRole(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return AdminPermissions.superAdmin();
      case AdminRole.admin:
        return AdminPermissions.admin();
      case AdminRole.moderator:
        return AdminPermissions.moderator();
      case AdminRole.support:
        return AdminPermissions.support();
    }
  }

  Future<void> _unbanUser() async {
    try {
      // Update user status
      await _firestore.collection('users').doc(widget.userId).update({
        'status': 'active',
        'bannedAt': FieldValue.delete(),
        'bannedReason': FieldValue.delete(),
      });

      // Create audit log
      final adminUser = ref.read(adminAuthControllerProvider).adminUser;
      await _firestore.collection('audit_logs').add({
        'adminId': adminUser?.id ?? 'unknown',
        'adminName': adminUser?.displayName ?? 'Unknown Admin',
        'action': 'user_unbanned',
        'targetType': 'user',
        'targetId': widget.userId,
        'details': {},
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User has been unbanned'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }

      // Reload data
      await _loadUserData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error unbanning user: $e')),
        );
      }
    }
  }
}
