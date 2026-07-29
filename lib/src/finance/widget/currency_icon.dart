import 'package:flutter/material.dart';
import 'package:my_api/src/finance/model/currency.dart';
import 'package:my_api/src/finance/widget/currency_symbol.dart';

/// Displays a currency symbol in a selectable icon container.
class CurrencyIcon extends StatelessWidget {

  /// Creates an icon for [currency].
  const CurrencyIcon(this.currency, {
    super.key,
    this.foreground,
    this.background = Colors.transparent,
    this.selected = false,
  });

  /// Symbol color.
  final Color? foreground;

  /// Icon background color.
  final Color background;

  /// Currency represented by the icon.
  final Currency currency;

  /// Whether to display the selection badge.
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
