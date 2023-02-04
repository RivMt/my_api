import 'package:flutter/material.dart';
import 'package:my_api/src/component/data_card.dart';
import 'package:my_api/src/model/category.dart';
import 'package:my_api/src/model/transaction.dart';

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
      main: Text(
        currency.format(amount),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      sub: Text(
        data.descriptions,
        style: Theme.of(context).textTheme.labelMedium,
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

  /// Icon
  IconData get icon {
    return category.icon.icon;
  }

  /// Icon color
  Color? get foreground {
    return getColor(data.type, data.included, false);
  }

  /// Background color
  Color? get background {
    return getColor(data.type, data.included, true);
  }

  /// Get color by [type], [included], and [background]
  Color? getColor(TransactionType type, bool included, bool background) {
    final level = background ? 300 : 500;
    switch(type) {
      case TransactionType.expense:
        if (included) {
          return Colors.red[level];
        } else {
          return Colors.orange[level];
        }
      case TransactionType.income:
        if (included) {
          return Colors.green[level];
        } else {
          return Colors.teal[level];
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: foreground,
      ),
    );
  }

}