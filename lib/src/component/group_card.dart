import 'package:flutter/material.dart';

class GroupCard extends StatefulWidget {
  const GroupCard({
    super.key,
    required this.title,
    required this.count,
    required this.build,
    this.onMorePressed,
  });

  /// Default width
  static const int width = 480;

  /// Default height
  static const int height = 260;

  /// Title
  final String title;

  /// Number of children
  final int count;

  /// Build list
  final Widget? Function(BuildContext, int) build;

  /// Triggers on right arrow button pressed
  final Function()? onMorePressed;

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
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
                  visible: (widget.onMorePressed != null),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right_outlined),
                    onPressed: widget.onMorePressed,
                  ),
                ),
              ],
            ),
            // Widgets
            ListView.builder(
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