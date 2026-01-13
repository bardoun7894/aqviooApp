import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/credits_provider.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../services/payment/tap_payment_service.dart';
import '../../../../services/payment/transaction_service.dart';
import '../../../../services/payment/iap_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io';

// Balance packages in SAR
class BalancePackage {
  final double amount; // SAR to add to balance
  final double price; // Price in SAR
  final String? badge;
  final bool isPopular;
  final int videosCount; // How many videos this can generate
  final int imagesCount; // How many images this can generate

  const BalancePackage({
    required this.amount,
    required this.price,
    this.badge,
    this.isPopular = false,
    required this.videosCount,
    required this.imagesCount,
  });
}

// Video: 2.99 SAR, Image: 1.99 SAR
const List<BalancePackage> balancePackages = [
  BalancePackage(amount: 15, price: 15.0, videosCount: 5, imagesCount: 7),
  BalancePackage(
      amount: 30,
      price: 30.0,
      isPopular: true,
      badge: 'Popular',
      videosCount: 10,
      imagesCount: 15),
  BalancePackage(
      amount: 50,
      price: 50.0,
      badge: 'Best Value',
      videosCount: 16,
      imagesCount: 25),
  BalancePackage(amount: 100, price: 100.0, videosCount: 33, imagesCount: 50),
];

// Legacy alias for backward compatibility
typedef CreditPackage = BalancePackage;
const List<BalancePackage> creditPackages = balancePackages;

class PaymentScreen extends ConsumerStatefulWidget {
  final double amount;

  const PaymentScreen({super.key, this.amount = 199.0});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _selectedPackageIndex = 1; // Default to popular package
  bool _isProcessing = false;

  // IAP Product IDs mapping to index
  final Map<int, String> _productIds = {
    0: 'credits_package_15',
    1: 'credits_package_30',
    2: 'credits_package_50',
    3: 'credits_package_100',
  };

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _initializeIAP();
    }
  }

  Future<void> _initializeIAP() async {
    final iapService = IAPService();
    await iapService.initialize();

    // Set callback to handle purchases
    iapService.onPurchaseUpdated = (PurchaseDetails purchaseDetails) {
      _handleIAPUpdate(purchaseDetails);
    };

    // Trigger rebuild to update UI if needed (though we use static list for now)
    if (mounted) setState(() {});
  }

  void _handleIAPUpdate(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      setState(() => _isProcessing = true);
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        setState(() => _isProcessing = false);
        _showErrorSnackBar(purchaseDetails.error?.message ?? 'Purchase failed');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Find which package was bought to know how much to credit
        // In a real app, verify receipt on backend.
        // Here we trust the productID to add credits.
        final productID = purchaseDetails.productID;
        final packageIndex = _productIds.entries
            .firstWhere((entry) => entry.value == productID,
                orElse: () => MapEntry(-1, ''))
            .key;

        if (packageIndex != -1) {
          final package = creditPackages[packageIndex];
          try {
            await ref
                .read(creditsControllerProvider.notifier)
                .addBalance(package.amount);
            if (mounted) {
              setState(() => _isProcessing = false);
              _showSuccessDialog(package);
            }
          } catch (e) {
            debugPrint('Error adding credits: $e');
            setState(() => _isProcessing = false);
          }
        } else {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final creditsState = ref.watch(creditsControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          l10n.buyCredits,
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Current Balance
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryPurple,
                  const Color(0xFF9D6BFF),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.currentBalance,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${creditsState.balance.toStringAsFixed(2)} ${Pricing.currency}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),

          // Credit Packages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: creditPackages.length,
              itemBuilder: (context, index) {
                final package = creditPackages[index];
                final isSelected = _selectedPackageIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPackageIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryPurple
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryPurple.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        // Radio indicator
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryPurple
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryPurple,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),

                        // Package info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${package.amount.toStringAsFixed(0)} ${Pricing.currency}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (package.badge != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: package.isPopular
                                            ? AppColors.primaryPurple
                                            : Colors.green,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        package.badge == 'Popular'
                                            ? l10n.popularBadge
                                            : l10n.bestValueBadge,
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.videosOrImages(
                                  '${package.videosCount}',
                                  '${package.imagesCount}',
                                ),
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Price
                        Text(
                          '${package.price.toStringAsFixed(0)} ${Pricing.currency}',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Purchase Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF2ACE82), // Tap green color
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.credit_card, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${l10n.payWithTap} - ${creditPackages[_selectedPackageIndex].price.toStringAsFixed(0)} SAR',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!Platform
                      .isIOS) // Only show Tap secure badge on Android/Web
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.securePaymentTap,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    // Platform-specific logic
    if (Platform.isIOS) {
      await _handleIOSPurchase();
    } else {
      await _handleTapPayment();
    }
  }

  Future<void> _handleIOSPurchase() async {
    final productId = _productIds[_selectedPackageIndex];
    if (productId == null) return;

    setState(() => _isProcessing = true);

    final iapService = IAPService();
    // Find product details
    try {
      final product = iapService.products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found'),
      );

      await iapService.buyConsumable(product);
      // Processing state will be updated by the listener
    } catch (e) {
      setState(() => _isProcessing = false);

      // If product not found (e.g. not configured in Connect yet), prompt user
      if (e.toString().contains('Product not found')) {
        _showErrorDialog(
            title: 'Store Error',
            message:
                'Product not configured in App Store. Please ensure product ID "$productId" exists.');
      } else {
        _showErrorSnackBar('Failed to initiate purchase: ${e.toString()}');
      }
    }
  }

  Future<void> _handleTapPayment() async {
    setState(() {
      _isProcessing = true;
    });
    final l10n = AppLocalizations.of(context)!;

    try {
      final package = creditPackages[_selectedPackageIndex];

      // Show Tap payment info dialog
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ACE82),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.payWithTap,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tapPaymentInfo,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.total,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${package.price.toStringAsFixed(0)} SAR',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.balanceToAdd,
                          style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${package.amount.toStringAsFixed(0)} ${Pricing.currency}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF2ACE82),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.tapPaymentMethods,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ACE82),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.continueToPayment,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

      if (shouldProceed != true) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Get user information
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        _showErrorSnackBar(l10n.paymentFailedMessage);
        return;
      }

      final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
      String? transactionId;

      try {
        // Create transaction record in Firestore (pending status)
        transactionId = await TransactionService().createTransaction(
          userId: user.uid,
          userName: user.displayName ?? 'User',
          userEmail: user.email ?? 'N/A',
          amount: package.price,
          currency: 'SAR',
          credits: package.amount.toInt(),
          orderId: orderId,
          paymentMethod: 'Tap',
          metadata: {
            'balanceAmount': package.amount,
            'packagePrice': package.price,
            'videosCount': package.videosCount,
            'imagesCount': package.imagesCount,
          },
        );
      } catch (e) {
        debugPrint('❌ Failed to create transaction record: $e');
        // Continue with payment even if record creation fails
      }

      // Get user name parts
      final nameParts = (user.displayName ?? 'User').split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Determine language
      final lang = Localizations.localeOf(context).languageCode;
      final isArabic = lang == 'ar';

      // Start Tap Payment (Checkout SDK) with complete configuration
      final paymentResult = await TapPaymentService().startPayment(
        amount: package.price,
        currency: 'SAR',
        customerEmail: user.email ?? 'user@aqvioo.com',
        customerPhone: user.phoneNumber ?? '+966500000001',
        customerFirstName: firstName,
        customerLastName: lastName,
        orderId: orderId,
        itemName:
            '${package.amount.toStringAsFixed(0)} SAR ${isArabic ? "رصيد" : "Balance"}',
        itemDescription: isArabic
            ? 'رصيد أكفيو لإنشاء الفيديو والصور بالذكاء الاصطناعي'
            : 'Aqvioo AI Video/Image Generation Balance',
        lang: lang,
        themeMode: TapThemeMode.light, // Match app's light theme
        supportedPaymentMethods: null, // ALL payment methods
      );

      if (!mounted) return;

      // Handle payment result
      if (paymentResult.success && paymentResult.chargeId != null) {
        // Verify transaction via API for additional security
        final verification = await TapPaymentService().verifyTransaction(
          paymentResult.chargeId!,
        );

        if (!mounted) return;

        if (verification.success &&
            (verification.isCaptured || verification.isAuthorized)) {
          // Payment verified - Update transaction status
          if (transactionId != null) {
            try {
              await TransactionService().updateTransactionStatus(
                transactionId: transactionId,
                status: verification.isCaptured
                    ? TransactionStatus.captured
                    : TransactionStatus.authorized,
              );
            } catch (e) {
              debugPrint('❌ Failed to update transaction status: $e');
            }
          }

          // Add balance in SAR
          try {
            await ref
                .read(creditsControllerProvider.notifier)
                .addBalance(package.amount);
          } catch (e) {
            debugPrint('❌ Failed to add balance: $e');
            // Still show success as payment was captured
          }

          if (!mounted) return;
          _showSuccessDialog(package);
        } else {
          // Verification failed
          if (transactionId != null) {
            try {
              await TransactionService().updateTransactionStatus(
                transactionId: transactionId,
                status: TransactionStatus.failed,
              );
            } catch (e) {
              debugPrint('❌ Failed to update transaction status: $e');
            }
          }

          if (!mounted) return;
          _showErrorSnackBar(
            isArabic
                ? 'فشل التحقق من الدفع. يرجى التواصل مع الدعم إذا تم خصم المبلغ.'
                : 'Payment verification failed. Please contact support if amount was deducted.',
          );
        }
      } else if (paymentResult.success) {
        // Success but no charge ID - still add balance (fallback)
        if (transactionId != null) {
          try {
            await TransactionService().updateTransactionStatus(
              transactionId: transactionId,
              status: TransactionStatus.authorized,
            );
          } catch (e) {
            debugPrint('❌ Failed to update transaction status: $e');
          }
        }

        try {
          await ref
              .read(creditsControllerProvider.notifier)
              .addBalance(package.amount);
        } catch (e) {
          debugPrint('❌ Failed to add balance: $e');
        }

        if (!mounted) return;
        _showSuccessDialog(package);
      } else {
        // Payment failed or cancelled
        if (transactionId != null) {
          try {
            await TransactionService().updateTransactionStatus(
              transactionId: transactionId,
              status: paymentResult.isCancelled
                  ? TransactionStatus.cancelled
                  : TransactionStatus.failed,
            );
          } catch (e) {
            debugPrint('❌ Failed to update transaction status: $e');
          }
        }

        if (!mounted) return;

        // Don't show error for user cancellation
        if (!paymentResult.isCancelled) {
          final errorMessage = TapPaymentService().getErrorMessage(
            errorCode: paymentResult.errorCode,
            isArabic: isArabic,
          );
          _showErrorSnackBar(errorMessage);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Tap Payment Error: $e');
      debugPrint('❌ Stack: $stackTrace');

      if (!mounted) return;

      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      _showErrorDialog(
        title: l10n.paymentFailedTitle,
        message: isArabic
            ? 'حدث خطأ أثناء معالجة الدفع. يرجى المحاولة مرة أخرى.'
            : 'An error occurred while processing payment. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.outfit(),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.outfit(color: AppColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(CreditPackage package) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.paymentSuccessTitle,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${package.amount.toStringAsFixed(0)} ${Pricing.currency} ${l10n.addedToBalance}',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  context.pop(); // Close payment screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.startCreatingButton,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
