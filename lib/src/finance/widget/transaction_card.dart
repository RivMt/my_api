import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/src/core/widget/data_card.dart';
import 'package:my_api/src/finance/widget/category_card.dart';
import 'package:my_api/src/finance/model/category.dart';
import 'package:my_api/src/finance/model/transaction.dart';
import 'package:my_api/src/finance/provider.dart' as finance_provider;

/// Displays a transaction amount, description, and category icon.
class TransactionCard extends ConsumerWidget {
  /// Creates a transaction card.
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

  /// Transaction to display.
  final Transaction data;

  /// Category associated with [data].
  final Category category;

  /// Whether the transaction is already paid.
  final bool isPaid;

  /// Pointer callbacks for the card.
  final Function()? onTap, onDoubleTap, onLongPress;

  /// Called when the pointer enters or leaves the card.
  final Function(bool)? onHover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = finance_provider.getCurrency(ref, data.nominalCurrencyId);
    final amount = data.nominalAmount;
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

/// Displays a transaction's category icon and status colors.
class TransactionIcon extends StatelessWidget {
  /// Creates an icon for [data] and [category].
  const TransactionIcon({
    super.key,
    required this.data,
    required this.category,
  });

  /// Transaction that determines type and status.
  final Transaction data;

  /// Category that supplies the glyph.
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
