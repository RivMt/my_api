import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/widget/data_card.dart';
import 'package:my_api/finance/widget/category_card.dart';
import 'package:my_api/finance/model/category.dart';
import 'package:my_api/finance/model/transaction.dart';
import 'package:my_api/finance/provider.dart' as finance_provider;

class TransactionCard extends ConsumerWidget {
  const TransactionCard({
    super.key,
    required this.data,
    required this.category,
    this.isPaid = true,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
  });

  /// Transaction
  final Transaction data;

  /// Category
  final Category category;

  /// Is paid
  final bool isPaid;

  /// Tap action
  final Function()? onTap, onDoubleTap, onLongPress;

  final Function(bool)? onHover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = finance_provider.getCurrency(ref, data.altCurrencyId ?? data.currencyId);
    final amount = data.altAmount ?? data.amount;
    return DataCard(
      leading: IndexedStack(
        index: isPaid ? 0 : 1,
        children: [
          // Paid
          TransactionIcon(
            data: data,
            category: category,
          ),
          // Not paid
          Badge(
            label: const Icon(
              Icons.watch_later_outlined,
              size: 12,
              color: Colors.white,
            ),
            child: TransactionIcon(
              data: data,
              category: category,
            ),
          ),
        ],
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