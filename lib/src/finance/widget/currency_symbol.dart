import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_api/src/core/log.dart';
import 'package:my_api/src/finance/model/currency.dart';

const String _tag = "CurrencySymbol";

/// Displays a currency's remote SVG icon or text-symbol fallback.
class CurrencySymbol extends StatelessWidget {

  /// Creates a symbol for [currency].
  const CurrencySymbol(this.currency, {
    super.key,
    this.color,
  });

  /// Currency represented by the symbol.
  final Currency currency;

  /// Optional SVG icon color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textSymbol = CurrencySymbolText(currency);
    if (currency.iconUrl.isEmpty) {
      return textSymbol;
    }
    final color = this.color ?? Theme.of(context).textTheme.labelMedium?.color ?? Colors.black;
    return SvgPicture.network(
      currency.iconUrl,
      semanticsLabel: currency.uuid,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (context) => textSymbol,
      errorBuilder: (context, o, s) {
        Log.e(_tag, "Unable to draw currency icon: ${currency.uuid} (${currency.iconUrl})");
        return textSymbol;
      },
    );
  }
}

/// Displays a currency's text symbol.
class CurrencySymbolText extends StatelessWidget {

  /// Currency represented by the text.
  final Currency currency;

  /// Creates a text symbol for [currency].
  const CurrencySymbolText(this.currency, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      currency.symbol,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
      semanticsLabel: currency.key,
    );
  }

}
