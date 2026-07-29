import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_api/src/core/widget/data_card.dart';
import 'package:my_api/src/finance/model/currency.dart';
import 'package:my_api/src/finance/widget/currency_icon.dart';

/// Displays a currency and, optionally, a formatted amount.
class CurrencyCard extends StatelessWidget {
  /// Creates a currency card.
  const CurrencyCard({
    super.key,
    required this.currency,
    this.amount,
    this.onTap,
    this.selected = false,
    this.useIconBackground = true,
  });

  /// Currency to display.
  final Currency currency;

  /// Optional amount formatted with [currency].
  final Decimal? amount;

  /// Whether to mark the currency as selected.
  final bool selected;

  /// Whether the currency icon has a colored background.
  final bool useIconBackground;

  /// Called when the card is tapped.
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return DataCard(
      color: Colors.transparent,
      leading: CurrencyIcon(
        currency,
        selected: selected,
        foreground: Theme.of(context).textTheme.titleMedium?.color,
        background: useIconBackground
            ? Theme.of(context).primaryColor
            : Colors.transparent,
      ),
      top: Text(
        currency.key.tr(),
        style: (amount != null)
            ? Theme.of(context).textTheme.labelMedium
            : Theme.of(context).textTheme.titleMedium,
        overflow: TextOverflow.fade,
        maxLines: 1,
      ),
      bottom: Visibility(
        visible: amount != null,
        child: Text(
          currency.format(amount ?? Decimal.zero),
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.fade,
          maxLines: 1,
        ),
      ),
      onTap: onTap,
    );
  }
}
