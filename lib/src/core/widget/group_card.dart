import 'package:flutter/material.dart';

/// Displays a titled, non-scrolling group of lazily built items.
class GroupCard extends StatefulWidget {
  /// Creates a grouped list card.
  const GroupCard({
    super.key,
    required this.title,
    required this.count,
    required this.build,
    this.button,
  });

  /// Default card width.
  static const int width = 480;

  /// Default card height.
  static const int height = 280;

  /// Group title.
  final String title;

  /// Number of list items.
  final int count;

  /// Optional action displayed at the top right.
  final Widget? button;

  /// Builds each list item.
  final Widget? Function(BuildContext, int) build;

  @override
  State createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  children: [
                    const SizedBox(width: 8,),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Visibility(
                  visible: widget.button != null,
                  child: widget.button ?? const SizedBox(),
                ),
              ],
            ),
            // Widgets
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.count,
              itemBuilder: widget.build,
            ),
          ],
        ),
      ),
    );
  }
}
