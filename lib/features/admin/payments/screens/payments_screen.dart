import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../services/payment/transaction_service.dart';
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
      // Load real transactions from Firestore
      final transactions = await TransactionService().getAllTransactions();
      double totalRevenue = 0.0;

      final List<Map<String, dynamic>> transactionMaps = [];

      for (var transaction in transactions) {
        // Calculate revenue from authorized/completed transactions
        if (transaction.status == TransactionStatus.authorized ||
            transaction.status == TransactionStatus.completed) {
          totalRevenue += transaction.amount;
        }

        transactionMaps.add({
          'id': transaction.id,
          'userId': transaction.userId,
          'userName': transaction.userName,
          'userEmail': transaction.userEmail,
          'amount': transaction.amount,
          'credits': transaction.credits,
          'status': transaction.status.name,
          'paymentMethod': transaction.paymentMethod,
          'createdAt': Timestamp.fromDate(transaction.createdAt),
          'orderId': transaction.orderId,
        });
      }

      // If no real transactions, fall back to estimated data for existing users
      if (transactionMaps.isEmpty) {
        final usersSnapshot = await _firestore.collection('users').get();

        for (var userDoc in usersSnapshot.docs) {
          final userData = userDoc.data();
          final creditsDoc = await _firestore
              .collection('users')
              .doc(userDoc.id)
              .collection('data')
              .doc('credits')
              .get();

          if (creditsDoc.exists) {
            final data = creditsDoc.data()!;
            final credits = data['credits'] as int? ?? 0;

            if (credits > 10) {
              final purchasedCredits = credits - 10;
              final amount = (purchasedCredits / 50) * 199.0;
              totalRevenue += amount;

              transactionMaps.add({
                'id': 'EST-${userDoc.id.substring(0, 8)}',
                'userId': userDoc.id,
                'userName': userData['displayName'] ?? 'Anonymous',
                'userEmail': userData['email'] ?? 'N/A',
                'amount': amount,
                'credits': purchasedCredits,
                'status': 'estimated',
                'paymentMethod': 'Tap',
                'createdAt': data['lastUpdated'] ?? Timestamp.now(),
              });
            }
          }
        }
      }

      setState(() {
        _transactions = transactionMaps;
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
      final matchesStatus =
          _statusFilter == 'all' || transaction['status'] == _statusFilter;

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
    // Check if we have real transactions (not estimated)
    final hasRealTransactions = _transactions.any(
      (t) => t['status'] != 'estimated',
    );

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
                  hasRealTransactions
                      ? 'Total Revenue'
                      : 'Total Revenue (Estimated)',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasRealTransactions
                            ? Icons.check_circle
                            : Icons.info_outline,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasRealTransactions
                            ? '${_transactions.length} transactions recorded'
                            : 'Showing estimated data',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Search - responsive width
            SizedBox(
              width: isWide ? 300 : constraints.maxWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkGray : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : AppColors.neuShadowDark.withOpacity(0.2),
                    width: 1,
                  ),
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
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by user or transaction ID...',
                    hintStyle: GoogleFonts.outfit(
                      color: isDark ? AppColors.mediumGray : AppColors.textHint,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? AppColors.mediumGray
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                  ),
                ),
              ),
            ),

            // Status Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkGray : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : AppColors.neuShadowDark.withOpacity(0.2),
                  width: 1,
                ),
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
              child: DropdownButton<String>(
                value: _statusFilter,
                onChanged: (value) => setState(() => _statusFilter = value!),
                underline: const SizedBox(),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color:
                      isDark ? AppColors.mediumGray : AppColors.textSecondary,
                ),
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
      },
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
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryPurple.withOpacity(0.15),
                    AppColors.primaryPurple.withOpacity(0.05),
                  ],
                ),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.primaryPurple.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No transactions found',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transactions will appear here once customers make purchases',
              style: GoogleFonts.outfit(
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use card layout for mobile/tablet, table for desktop
        if (constraints.maxWidth < 800) {
          return _buildTransactionCards(transactions, isDark);
        }
        return _buildTransactionDataTable(transactions, isDark);
      },
    );
  }

  Widget _buildTransactionCards(
      List<Map<String, dynamic>> transactions, bool isDark) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final createdAt = (transaction['createdAt'] as Timestamp).toDate();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkGray : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : AppColors.neuShadowDark.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.2)
                    : AppColors.neuShadowDark.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row - ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : AppColors.lightGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction['id'],
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? AppColors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction['status'])
                            .withOpacity(0.1),
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
                  ],
                ),
                const SizedBox(height: 16),

                // User info
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.primaryPurple,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction['userName'],
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            transaction['userEmail'],
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
                  ],
                ),
                const SizedBox(height: 16),

                // Amount and Credits row
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : AppColors.lightGray.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.mediumGray
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${transaction['amount'].toStringAsFixed(2)} SAR',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : AppColors.neuShadowDark.withOpacity(0.2),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Credits',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.mediumGray
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.bolt,
                                  size: 18,
                                  color: AppColors.primaryPurple,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${transaction['credits']}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Footer - Method and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.payment_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.mediumGray
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          transaction['paymentMethod'],
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.mediumGray
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(createdAt),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color:
                            isDark ? AppColors.mediumGray : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionDataTable(
      List<Map<String, dynamic>> transactions, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.neuShadowDark.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : AppColors.neuShadowDark.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              isDark
                  ? Colors.white.withOpacity(0.05)
                  : AppColors.lightGray.withOpacity(0.5),
            ),
            dataRowMinHeight: 72,
            dataRowMaxHeight: 88,
            horizontalMargin: 24,
            columnSpacing: 32,
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
              final createdAt =
                  (transaction['createdAt'] as Timestamp).toDate();

              return DataRow(
                cells: [
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : AppColors.lightGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction['id'],
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? AppColors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: AppColors.primaryPurple,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              transaction['userName'],
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.textPrimary,
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
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      '${transaction['amount'].toStringAsFixed(2)} SAR',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt,
                            size: 14,
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${transaction['credits']}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        Icon(
                          Icons.payment_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.mediumGray
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          transaction['paymentMethod'],
                          style: GoogleFonts.outfit(
                            color: isDark
                                ? AppColors.mediumGray
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction['status'])
                            .withOpacity(0.1),
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
                        color: isDark
                            ? AppColors.mediumGray
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
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
