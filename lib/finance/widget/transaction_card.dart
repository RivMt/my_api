import 'package:flutter/material.dart';
import 'package:my_api/core/widget/data_card.dart';
import 'package:my_api/finance/widget/category_card.dart';
import 'package:my_api/finance/model/category.dart';
import 'package:my_api/finance/model/transaction.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.data,
    required this.category,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
  });

  /// Transaction
  final Transaction data;

  /// Category
  final Category category;

  /// Tap action
  final Function()? onTap, onDoubleTap, onLongPress;

  final Function(bool)? onHover;

  @override
  Widget build(BuildContext context) {
    final currency = data.altCurrency ?? data.currency;
    final amount = data.altAmount ?? data.amount;
    return DataCard(
      leading: TransactionIcon(
        data: data,
        category: category,
      ),
      top: Text(
        currency.format(amount),
        style: Theme.of(context).textTheme.titleMedium,
        overflow: TextOverflow.clip,
        maxLines: 1,
      ),
      bottom: Visibility(
        visible: data.descriptions.isNotEmpty,
        child: Text(
          data.descriptions,
          style: Theme.of(context).textTheme.labelMedium,
          overflow: TextOverflow.clip,
          maxLines: 1,
        ),
      ),
      color: Colors.transparent,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onHover: onHover,
    );
  }
}

class TransactionIcon extends StatelessWidget {
  const TransactionIcon({
    super.key,
    required this.data,
    required this.category,
  });

  /// Transaction
  final Transaction data;

  /// Category
  final Category category;

  @override
  Widget build(BuildContext context) {
    return CategoryIcon(
      type: data.type,
      icon: category.icon.icon,
      included: data.isIncluded,
      isDeleted: data.deleted,
    );
  }

}