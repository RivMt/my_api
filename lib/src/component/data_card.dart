import 'package:flutter/material.dart';

class DataCard extends StatefulWidget {
  const DataCard({
    super.key,
    required this.leading,
    required this.main,
    required this.sub,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
  });

  final Widget leading, main, sub;

  final Function()? onTap, onDoubleTap, onLongPress;

  final Function(bool)? onHover;

  @override
  _DataCardState createState() => _DataCardState();
}

class _DataCardState extends State<DataCard> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      onHover: widget.onHover,
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.leading,
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.main,
              widget.sub,
            ],
          ),
        ],
      ),
    );
  }
}