import 'package:flutter/material.dart';
import 'package:my_api/src/core/theme.dart';
import 'package:my_api/src/core/widget/data_card.dart';
import 'package:my_api/src/finance/model/category.dart';
import 'package:my_api/src/finance/model/transaction.dart';

/// Displays a category summary with its semantic icon.
class CategoryCard extends StatelessWidget {
  /// Creates a category card.
  const CategoryCard({
    super.key,
    required this.category,
    this.unknownMessage,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
  });

  /// Standard card height.
  static const int height = 72;

  /// Category to display.
  final Category category;

  /// Message displayed for [Category.unknown].
  final String? unknownMessage;

  /// Pointer callbacks for the card.
  final Function()? onTap, onDoubleTap, onLongPress;

  /// Called when the pointer enters or leaves the card.
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
        isDeleted: category.deleted,
      ),
      top: Text(
        category.name,
        style: Theme.of(context).textTheme.titleMedium,
        overflow: TextOverflow.clip,
        maxLines: 1,
      ),
      bottom: Visibility(
        visible: category.descriptions.isNotEmpty,
        child: Text(
          category.descriptions,
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

/// Displays a category icon colored by transaction type and status.
class CategoryIcon extends StatelessWidget {
  /// Creates a category icon from explicit values.
  const CategoryIcon({
    super.key,
    required this.type,
    this.icon = Icons.circle_outlined,
    this.included = true,
    this.isDeleted = false,
    this.foreground,
    this.background,
  });

  /// Creates an icon from [category].
  CategoryIcon.fromCategory(Category category, {super.key})
      : type = category.type,
        icon = category.icon.icon,
        included = category.isIncluded,
        isDeleted = category.deleted,
        foreground = null,
        background = null;


  /// Glyph to display.
  final IconData icon;

  /// Transaction type that determines the color.
  final TransactionType type;

  /// Whether the category is included in statistics.
  final bool included;

  /// Whether to use disabled colors.
  final bool isDeleted;

  /// Optional color overrides.
  final Color? foreground, background;

  /// Resolved icon color.
  Color? get foregroundColor {
    if (foreground != null) {
      return foreground;
    }
    if (isDeleted) {
      return AppTheme.swatches.disabledForeground;
    }
    return getColor(type, included, false);
  }

  /// Resolved background color.
  Color? get backgroundColor {
    if (background != null) {
      return background;
    }
    if (isDeleted) {
      return AppTheme.swatches.disabledBackground;
    }
    return getColor(type, included, true);
  }

  /// Resolves a color for [type], inclusion, and layer.
  Color? getColor(TransactionType type, bool included, bool background) {
    final level = background ? 100 : 500;
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
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: foregroundColor,
      ),
    );
  }

}
