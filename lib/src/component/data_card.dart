import 'package:flutter/material.dart';

class DataCard extends StatefulWidget {
  const DataCard({
    super.key,
    required this.leading,
    required this.main,
    required this.sub,
    this.color,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
  });

  final Widget leading, main, sub;

  final Color? color;

  final Function()? onTap, onDoubleTap, onLongPress;

  final Function(bool)? onHover;

  @override
  _DataCardState createState() => _DataCardState();
}

class _DataCardState extends State<DataCard> {

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.color,
      child: InkWell(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onLongPress: widget.onLongPress,
        onHover: widget.onHover,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.leading,
              const SizedBox(width: 8,),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.main,
                  widget.sub,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}