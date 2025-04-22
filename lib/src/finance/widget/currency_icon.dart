import 'package:flutter/material.dart';
import 'package:my_api/src/finance/model/currency.dart';
import 'package:my_api/src/finance/widget/currency_symbol.dart';

class CurrencyIcon extends StatelessWidget {

  const CurrencyIcon(this.currency, {
    super.key,
    this.foreground,
    this.background = Colors.transparent,
    this.selected = false,
  });

  final Color? foreground;

  final Color background;

  final Currency currency;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: selected,
      backgroundColor: Theme.of(context).primaryColor,
      child: Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(4),
        ),
        child: CurrencySymbol(currency,
          color: foreground,
        ),
      ),
    );
  }
}