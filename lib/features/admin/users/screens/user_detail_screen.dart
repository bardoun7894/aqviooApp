import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../dashboard/screens/admin_scaffold.dart';
import '../../auth/providers/admin_auth_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Get user data
      final userDoc = await _firestore.collection('users').doc(widget.userId).get();
      if (!userDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
        return;
      }

      _userData = userDoc.data();

      // Get credits
      final creditsDoc = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('data')
          .doc('credits')
          .get();

      _userCredits = creditsDoc.exists
          ? (creditsDoc.data()?['credits'] as int? ?? 0)
          : 0;

      // Get creations
      final creationsSnapshot = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('creations')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      _creations = creationsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

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
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))],
                style: GoogleFonts.outfit(
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount (+ to add, - to subtract)',
                  labelStyle: GoogleFonts.outfit(
                    color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
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
                    color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'bonus', child: Text('Bonus')),
                  DropdownMenuItem(value: 'refund', child: Text('Refund')),
                  DropdownMenuItem(value: 'correction', child: Text('Correction')),
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
                    color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
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

      // Update credits
      await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('data')
          .doc('credits')
          .update({
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
          _buildInfoRow('Email', _userData?['email'] ?? 'N/A', Icons.email_outlined, isDark),
          const SizedBox(height: 12),
          _buildInfoRow('Phone', _userData?['phoneNumber'] ?? 'N/A', Icons.phone_outlined, isDark),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Joined',
            _userData?['createdAt'] != null
                ? DateFormat('MMM d, y').format((_userData!['createdAt'] as Timestamp).toDate())
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
                    color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
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
    final createdAt = (creation['createdAt'] as Timestamp?)?.toDate();
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
                createdAt != null ? DateFormat('MMM d, y • h:mm a').format(createdAt) : 'Unknown date',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
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
}
