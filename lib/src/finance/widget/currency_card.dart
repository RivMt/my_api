import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_api/src/core/widget/data_card.dart';
import 'package:my_api/src/finance/model/currency.dart';
import 'package:my_api/src/finance/widget/currency_icon.dart';

class CurrencyCard extends StatelessWidget {
  const CurrencyCard({
    super.key,
    required this.currency,
    this.amount,
    this.onTap,
    this.selected = false,
    this.useIconBackground = true,
  });

  final Currency currency;

  final Decimal? amount;

  final bool selected;

  final bool useIconBackground;

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

