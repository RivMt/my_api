import 'package:flutter/material.dart';

class GroupCard extends StatefulWidget {
  const GroupCard({
    super.key,
    required this.title,
    required this.count,
    required this.build,
  });

  final String title;

  final int count;

  final Widget? Function(BuildContext, int) build;

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium,
              )
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
    );
  }
}