import 'package:flutter/material.dart';

class RiyalSymbol extends StatelessWidget {
  final double? fontSize;
  final Color? color;
  final bool isBold;
  final bool useNewUnicode;

  const RiyalSymbol({
    super.key,
    this.fontSize,
    this.color,
    this.isBold = false,
    this.useNewUnicode = true,
  });

  @override
  Widget build(BuildContext context) {
    // \u20c1 is the new Unicode currency sign for Saudi Riyal (Unicode 17+)
    // \ue900 is the legacy private-use code point
    final String symbol = useNewUnicode ? '\u20c1' : '\ue900';

    return Text(
      symbol,
      style: TextStyle(
        fontFamily: 'SaudiRiyal',
        fontSize: (fontSize ?? 14) * 1.2,
        color: color,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
