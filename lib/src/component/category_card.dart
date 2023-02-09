import 'package:flutter/material.dart';
import 'package:my_api/src/component/data_card.dart';
import 'package:my_api/src/model/category.dart';
import 'package:my_api/src/model/transaction.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    this.unknownMessage,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
  });

  /// Card height
  static const int height = 72;

  /// Category
  final Category category;

  /// Unknown message
  final String? unknownMessage;

  /// Tap action
  final Function()? onTap, onDoubleTap, onLongPress;

  final Function(bool)? onHover;

  @override
  Widget build(BuildContext context) {
    return DataCard(
      isUnknown: category == Category.unknown,
      unknownMessage: unknownMessage,
      leading: CategoryIcon(
        type: category.type,
        icon: category.icon.icon,
        included: category.isIncluded,
      ),
      main: Text(
        category.name,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      sub: Text(
        category.descriptions,
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

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.type,
    this.icon = Icons.circle_outlined,
    this.included = true,
  });

  /// Icon
  final IconData icon;

  /// Type
  final TransactionType type;

  /// Included
  final bool included;

  /// Icon color
  Color? get foreground {
    return getColor(type, included, false);
  }

  /// Background color
  Color? get background {
    return getColor(type, included, true);
  }

  /// Get color by [type], [included], and [background]
  Color? getColor(TransactionType type, bool included, bool background) {
    final level = background ? 200 : 500;
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
      case TransactionType.unknown:
        return Colors.grey[level];
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