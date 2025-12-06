import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/creation/domain/models/creation_config.dart';

/// Pricing in SAR (Saudi Riyal)
class Pricing {
  static const double videoCost = 2.99;  // SAR per video
  static const double imageCost = 1.99;  // SAR per image
  static const double initialBalance = 10.0;  // SAR for new users
  static const String currency = 'ر.س';  // Saudi Riyal symbol
  static const String currencyCode = 'SAR';
}

class CreditsState {
  final double balance;  // Balance in SAR
  final bool hasGeneratedFirst;
  final bool isLoading;

  const CreditsState({
    required this.balance,
    required this.hasGeneratedFirst,
    this.isLoading = false,
  });

  /// For backward compatibility - returns balance as int credits
  int get credits => balance.floor();

  CreditsState copyWith({
    double? balance,
    bool? hasGeneratedFirst,
    bool? isLoading,
  }) {
    return CreditsState(
      balance: balance ?? this.balance,
      hasGeneratedFirst: hasGeneratedFirst ?? this.hasGeneratedFirst,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CreditsController extends StateNotifier<CreditsState> {
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _cacheBalanceKey = 'cached_user_balance_sar';
  static const String _cacheFirstGenKey = 'cached_has_generated_first';

  CreditsController(this.ref)
      : super(const CreditsState(
          balance: Pricing.initialBalance,
          hasGeneratedFirst: false,
        )) {
    _loadBalance();
  }

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference? get _userCreditsDoc {
    final userId = _userId;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('data').doc('credits');
  }

  Future<void> _loadBalance() async {
    state = state.copyWith(isLoading: true);

    try {
      final userId = _userId;

      if (userId == null) {
        state = CreditsState(
          balance: Pricing.initialBalance,
          hasGeneratedFirst: false,
          isLoading: false,
        );
        return;
      }

      // Load from cache first
      final prefs = await SharedPreferences.getInstance();
      final cachedBalance = prefs.getDouble(_cacheBalanceKey);
      final cachedFirstGen = prefs.getBool(_cacheFirstGenKey);

      if (cachedBalance != null) {
        state = state.copyWith(
          balance: cachedBalance,
          hasGeneratedFirst: cachedFirstGen ?? false,
        );
      }

      // Load from Firebase
      final doc = await _userCreditsDoc?.get();

      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Support both old 'credits' (int) and new 'balance' (double) fields
        double balance;
        if (data.containsKey('balance')) {
          balance = (data['balance'] as num).toDouble();
        } else if (data.containsKey('credits')) {
          // Migrate old credits to SAR balance (1 credit = 1 SAR for migration)
          balance = (data['credits'] as num).toDouble();
        } else {
          balance = Pricing.initialBalance;
        }

        final hasGeneratedFirst = data['hasGeneratedFirst'] as bool? ??
                                   data['hasGeneratedFirstVideo'] as bool? ?? false;

        // Update cache
        await prefs.setDouble(_cacheBalanceKey, balance);
        await prefs.setBool(_cacheFirstGenKey, hasGeneratedFirst);

        state = CreditsState(
          balance: balance,
          hasGeneratedFirst: hasGeneratedFirst,
          isLoading: false,
        );
      } else {
        // First time user
        await _userCreditsDoc?.set({
          'balance': Pricing.initialBalance,
          'hasGeneratedFirst': false,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        await prefs.setDouble(_cacheBalanceKey, Pricing.initialBalance);
        await prefs.setBool(_cacheFirstGenKey, false);

        state = CreditsState(
          balance: Pricing.initialBalance,
          hasGeneratedFirst: false,
          isLoading: false,
        );
      }
    } catch (e) {
      print('Error loading balance: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Get cost in SAR for output type
  double getCost(OutputType outputType) {
    return outputType == OutputType.video
        ? Pricing.videoCost
        : Pricing.imageCost;
  }

  /// For backward compatibility
  int getCreditCost(OutputType outputType) {
    return getCost(outputType).ceil();
  }

  /// Check if user can afford generation
  Future<bool> canGenerate(OutputType outputType) async {
    final cost = getCost(outputType);
    return state.balance >= cost;
  }

  /// Deduct cost for generation
  Future<void> deductCreditsForGeneration(OutputType outputType) async {
    try {
      final userId = _userId;
      if (userId == null) throw Exception('User not logged in');

      final cost = getCost(outputType);
      final newBalance = state.balance - cost;

      if (newBalance < 0) throw Exception('Insufficient balance');

      // Update Firestore
      await _userCreditsDoc?.update({
        'balance': newBalance,
        'hasGeneratedFirst': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_cacheBalanceKey, newBalance);
      await prefs.setBool(_cacheFirstGenKey, true);

      // Update state
      state = state.copyWith(
        balance: newBalance,
        hasGeneratedFirst: true,
      );
    } catch (e) {
      print('Error deducting balance: $e');
      rethrow;
    }
  }

  /// Add balance (from payment) - amount in SAR
  Future<void> addBalance(double amount) async {
    try {
      final userId = _userId;
      if (userId == null) throw Exception('User not logged in');

      final newBalance = state.balance + amount;

      // Update Firestore
      await _userCreditsDoc?.update({
        'balance': newBalance,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_cacheBalanceKey, newBalance);

      // Update state
      state = state.copyWith(balance: newBalance);
    } catch (e) {
      print('Error adding balance: $e');
      rethrow;
    }
  }

  /// For backward compatibility - add credits as SAR
  Future<void> addCredits(int amount) async {
    await addBalance(amount.toDouble());
  }

  /// Reload balance from server
  Future<void> refreshBalance() async {
    await _loadBalance();
  }
}

final creditsControllerProvider =
    StateNotifierProvider<CreditsController, CreditsState>((ref) {
  return CreditsController(ref);
});
