import 'package:flutter/material.dart';

class GroupCard extends StatefulWidget {
  const GroupCard({
    super.key,
    required this.title,
    this.children = const [],
  });

  final String title;

  final List<Widget> children;

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          // Widgets
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.children.length,
            itemBuilder: (BuildContext context, int index) {
              return widget.children[index];
            },
          ),
        ],
      ),
    );
  }
}