import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/riyal_symbol.dart';

class CurrencyUtils {
  static final _currencyFormatter = NumberFormat.currency(
    symbol: '',
    decimalDigits: 2,
  );

  /// Formats a number as a currency string without the symbol.
  static String formatAmount(double amount) {
    return _currencyFormatter.format(amount);
  }

  /// Returns a Row with the formatted amount and the Saudi Riyal symbol.
  static Widget buildPriceRow(
    double amount, {
    TextStyle? amountStyle,
    double? symbolSize,
    Color? symbolColor,
    bool isBold = false,
    String? prefix,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (prefix != null)
          Text(
            prefix,
            style: amountStyle,
          ),
        RiyalSymbol(
          fontSize: symbolSize ?? amountStyle?.fontSize,
          color: symbolColor ?? amountStyle?.color,
          isBold: isBold,
        ),
        const SizedBox(width: 4),
        Text(
          formatAmount(amount),
          style: amountStyle,
        ),
      ],
    );
  }
}
