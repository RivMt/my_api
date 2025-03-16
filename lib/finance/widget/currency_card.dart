import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_api/core/widget/data_card.dart';
import 'package:my_api/finance/model/currency.dart';

class CurrencyCard extends StatelessWidget {
  const CurrencyCard({
    super.key,
    required this.data,
    this.amount,
    this.onTap,
    this.selected = false,
    this.useIconBackground = true,
  });

  final Currency data;

  final Decimal? amount;

  final bool selected;

  final bool useIconBackground;

  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return DataCard(
      color: Colors.transparent,
      leading: CurrencyIcon(
        iconUrl: data.iconUrl,
        selected: selected,
        background: useIconBackground
            ? Theme.of(context).primaryColor
            : Colors.transparent,
      ),
      top: Text(
        data.key.tr(),
        style: (amount != null)
            ? Theme.of(context).textTheme.labelMedium
            : Theme.of(context).textTheme.titleMedium,
        overflow: TextOverflow.fade,
        maxLines: 1,
      ),
      bottom: Visibility(
        visible: amount != null,
        child: Text(
          data.format(amount ?? Decimal.zero),
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.fade,
          maxLines: 1,
        ),
      ),
      onTap: onTap,
    );
  }
}

class CurrencyIcon extends StatelessWidget {

  const CurrencyIcon({
    super.key,
    required this.background,
    required this.iconUrl,
    this.selected = false,
  });

  final Color background;

  final String iconUrl;

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
        child: SvgPicture.network(iconUrl),
      ),
    );
  }
}