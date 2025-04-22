import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_api/src/core/log.dart';
import 'package:my_api/src/finance/model/currency.dart';

const String _tag = "CurrencySymbol";

class CurrencySymbol extends StatelessWidget {

  const CurrencySymbol(this.currency, {
    super.key,
    this.color,
  });

  final Currency currency;

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

class CurrencySymbolText extends StatelessWidget {

  final Currency currency;

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