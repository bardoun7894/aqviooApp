import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../dashboard/screens/admin_scaffold.dart';

/// Payments Screen - View and manage payment transactions
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';
  double _totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Replace with actual transactions collection when Tabby webhooks are implemented
      // For now, we'll estimate from credit history

      final usersSnapshot = await _firestore.collection('users').get();
      final List<Map<String, dynamic>> estimatedTransactions = [];
      double totalRevenue = 0.0;

      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();

        // Get credit data
        final creditsDoc = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('data')
            .doc('credits')
            .get();

        if (creditsDoc.exists) {
          final data = creditsDoc.data()!;
          final credits = data['credits'] as int? ?? 0;

          // Estimate transactions based on credits
          // Assuming initial 10 credits are free
          if (credits > 10) {
            final purchasedCredits = credits - 10;
            final amount = (purchasedCredits / 50) * 199.0; // Estimate based on 50 credits = 199 SAR

            totalRevenue += amount;

            estimatedTransactions.add({
              'id': 'EST-${userDoc.id.substring(0, 8)}',
              'userId': userDoc.id,
              'userName': userData['displayName'] ?? 'Anonymous',
              'userEmail': userData['email'] ?? 'N/A',
              'amount': amount,
              'credits': purchasedCredits,
              'status': 'estimated',
              'paymentMethod': 'Tabby',
              'createdAt': data['lastUpdated'] ?? Timestamp.now(),
            });
          }
        }
      }

      // Sort by date
      estimatedTransactions.sort((a, b) {
        final aDate = (a['createdAt'] as Timestamp).toDate();
        final bDate = (b['createdAt'] as Timestamp).toDate();
        return bDate.compareTo(aDate);
      });

      setState(() {
        _transactions = estimatedTransactions;
        _totalRevenue = totalRevenue;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    return _transactions.where((transaction) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          transaction['userName']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          transaction['userEmail']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          transaction['id']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus = _statusFilter == 'all' ||
          transaction['status'] == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    final filteredTransactions = _filteredTransactions;

    return AdminScaffold(
      currentRoute: '/admin/payments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(isDark),
          const SizedBox(height: 24),

          // Revenue Summary
          _buildRevenueSummary(isDark),
          const SizedBox(height: 24),

          // Search and Filters
          _buildSearchAndFilters(isDark),
          const SizedBox(height: 24),

          // Transactions Table
          Expanded(
            child: _isLoading
                ? _buildLoadingState(isDark)
                : _buildTransactionsTable(filteredTransactions, isDark),
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
              'Payment Transactions',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_transactions.length} transactions',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _loadTransactions,
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

  Widget _buildRevenueSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF047857)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Revenue (Estimated)',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_totalRevenue.toStringAsFixed(2)} SAR',
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Note: Tabby webhooks not yet implemented',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.account_balance_wallet_rounded,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
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
              hintText: 'Search by user or transaction ID...',
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkGray : AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: _statusFilter,
            onChanged: (value) => setState(() => _statusFilter = value!),
            underline: const SizedBox(),
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
            dropdownColor: isDark ? AppColors.darkGray : AppColors.white,
            items: const {
              'all': 'All Status',
              'estimated': 'Estimated',
              'success': 'Success',
              'pending': 'Pending',
              'failed': 'Failed',
            }.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
      ),
    );
  }

  Widget _buildTransactionsTable(
      List<Map<String, dynamic>> transactions, bool isDark) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: isDark ? AppColors.mediumGray : AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
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
                'Transaction ID',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
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
                'Amount',
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
                'Method',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Date',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
          rows: transactions.map((transaction) {
            final createdAt = (transaction['createdAt'] as Timestamp).toDate();

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    transaction['id'],
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        transaction['userName'],
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        transaction['userEmail'],
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.mediumGray
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    '${transaction['amount'].toStringAsFixed(2)} SAR',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${transaction['credits']}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    transaction['paymentMethod'],
                    style: GoogleFonts.outfit(
                      color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      transaction['status'].toString().toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _getStatusColor(transaction['status']),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    DateFormat('MMM d, y • h:mm a').format(createdAt),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
      case 'estimated':
        return const Color(0xFF059669);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'failed':
        return const Color(0xFFDC2626);
      default:
        return AppColors.mediumGray;
    }
  }
}
