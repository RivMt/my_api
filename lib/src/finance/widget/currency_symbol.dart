import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_api/src/core/log.dart';
import 'package:my_api/src/finance/model/currency.dart';

const String _tag = "CurrencySymbol";

/// Displays a currency's remote SVG icon or text-symbol fallback.
class CurrencySymbol extends StatelessWidget {
  /// Creates a symbol for [currency].
  const CurrencySymbol(
    this.currency, {
    super.key,
    this.color,
  });

  /// Currency represented by the symbol.
  final Currency currency;

  /// Optional SVG icon color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color ??
        Theme.of(context).textTheme.labelMedium?.color ??
        Colors.black;
    final assetSymbol = _CurrencyAssetSymbol(currency, color: color);
    if (currency.iconUrl.trim().isEmpty) {
      return assetSymbol;
    }
    return SvgPicture.network(
      currency.iconUrl,
      semanticsLabel: currency.uuid,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (context) => assetSymbol,
      errorBuilder: (context, o, s) {
        Log.e(_tag,
            "Unable to draw currency icon: ${currency.uuid} (${currency.iconUrl})");
        return assetSymbol;
      },
    );
  }
}

class _CurrencyAssetSymbol extends StatelessWidget {
  const _CurrencyAssetSymbol(this.currency, {required this.color});

  final Currency currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textSymbol = CurrencySymbolText(currency, color: color);
    return SvgPicture.asset(
      currency.assetUri,
      package: 'my_api',
      semanticsLabel: currency.uuid,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (context) => textSymbol,
      errorBuilder: (context, o, s) {
        Log.e(_tag,
            "Unable to draw currency asset: ${currency.uuid} (${currency.assetUri})");
        return textSymbol;
      },
    );
  }
}

/// Displays a currency's text symbol.
class CurrencySymbolText extends StatelessWidget {
  /// Currency represented by the text.
  final Currency currency;

  /// Optional text-symbol color.
  final Color? color;

  /// Creates a text symbol for [currency].
  const CurrencySymbolText(this.currency, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      currency.symbol,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
      textAlign: TextAlign.center,
      semanticsLabel: currency.key,
    );
  }
}
