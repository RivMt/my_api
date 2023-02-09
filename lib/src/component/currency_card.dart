import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_api/src/component/data_card.dart';
import 'package:my_api/src/model/currency.dart';

class CurrencyCard extends StatelessWidget {
  const CurrencyCard({
    super.key,
    required this.data,
    this.amount,
  });

  final Currency data;

  final Decimal? amount;

  @override
  Widget build(BuildContext context) {
    return DataCard(
      leading: CurrencyIcon(
        icon: data.icon,
        foreground: Colors.white,
        background: Theme.of(context).primaryColor,
      ),
      top: Text(
        data.key.tr(),
        style: Theme.of(context).textTheme.labelMedium,
      ),
      bottom: Text(
        data.format(amount ?? Decimal.zero),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class CurrencyIcon extends StatelessWidget {

  const CurrencyIcon({
    super.key,
    required this.foreground,
    required this.background,
    required this.icon,
    this.selected = false,
  });

  final Color foreground, background;

  final IconData icon;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: selected,
      backgroundColor: foreground,
      child: Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          color: foreground,
        ),
      ),
    );
  }
}