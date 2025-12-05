import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Transaction status enum
enum TransactionStatus {
  pending,
  authorized,
  completed,
  failed,
  refunded,
}

/// Transaction model
class PaymentTransaction {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final double amount;
  final String currency;
  final int credits;
  final String paymentMethod;
  final TransactionStatus status;
  final String? orderId;
  final String? tabbyPaymentId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  PaymentTransaction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.amount,
    required this.currency,
    required this.credits,
    required this.paymentMethod,
    required this.status,
    this.orderId,
    this.tabbyPaymentId,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  factory PaymentTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userEmail: data['userEmail'] ?? 'N/A',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] ?? 'SAR',
      credits: data['credits'] as int? ?? 0,
      paymentMethod: data['paymentMethod'] ?? 'Tabby',
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TransactionStatus.pending,
      ),
      orderId: data['orderId'],
      tabbyPaymentId: data['tabbyPaymentId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'amount': amount,
      'currency': currency,
      'credits': credits,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'orderId': orderId,
      'tabbyPaymentId': tabbyPaymentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'metadata': metadata,
    };
  }
}

/// Service to manage payment transactions in Firestore
class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'transactions';

  /// Create a new pending transaction before payment
  Future<String> createTransaction({
    required String userId,
    required String userName,
    required String userEmail,
    required double amount,
    required String currency,
    required int credits,
    required String orderId,
    String paymentMethod = 'Tabby',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'amount': amount,
        'currency': currency,
        'credits': credits,
        'paymentMethod': paymentMethod,
        'status': TransactionStatus.pending.name,
        'orderId': orderId,
        'createdAt': FieldValue.serverTimestamp(),
        'metadata': metadata,
      });

      debugPrint('Transaction created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      rethrow;
    }
  }

  /// Update transaction status after payment result
  Future<void> updateTransactionStatus({
    required String transactionId,
    required TransactionStatus status,
    String? tabbyPaymentId,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status.name,
      };

      if (tabbyPaymentId != null) {
        updates['tabbyPaymentId'] = tabbyPaymentId;
      }

      if (status == TransactionStatus.completed ||
          status == TransactionStatus.authorized) {
        updates['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection(_collection).doc(transactionId).update(updates);
      debugPrint('Transaction $transactionId updated to ${status.name}');
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  /// Get all transactions (for admin)
  Future<List<PaymentTransaction>> getAllTransactions({
    int? limit,
    TransactionStatus? statusFilter,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true);

      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter.name);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PaymentTransaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting transactions: $e');
      return [];
    }
  }

  /// Get transactions for a specific user
  Future<List<PaymentTransaction>> getUserTransactions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PaymentTransaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting user transactions: $e');
      return [];
    }
  }

  /// Get total revenue from completed transactions
  Future<double> getTotalRevenue() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', whereIn: [
            TransactionStatus.completed.name,
            TransactionStatus.authorized.name,
          ])
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        total += (data['amount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      debugPrint('Error calculating revenue: $e');
      return 0.0;
    }
  }

  /// Get transaction by order ID
  Future<PaymentTransaction?> getTransactionByOrderId(String orderId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return PaymentTransaction.fromFirestore(snapshot.docs.first);
    } catch (e) {
      debugPrint('Error getting transaction by order ID: $e');
      return null;
    }
  }

  /// Stream transactions for real-time updates (admin dashboard)
  Stream<List<PaymentTransaction>> streamTransactions({int? limit}) {
    Query query = _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => PaymentTransaction.fromFirestore(doc)).toList());
  }
}
