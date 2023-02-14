import 'package:flutter/material.dart';

class GroupCard extends StatefulWidget {
  const GroupCard({
    super.key,
    required this.title,
    required this.count,
    required this.build,
    this.button,
  });

  /// Default width
  static const int width = 480;

  /// Default height
  static const int height = 280;

  /// Title
  final String title;

  /// Number of children
  final int count;

  /// Top-right button
  final Widget? button;

  /// Build list
  final Widget? Function(BuildContext, int) build;

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
                  visible: widget.button != null,
                  child: widget.button ?? const SizedBox(),
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