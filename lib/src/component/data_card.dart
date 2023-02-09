import 'package:flutter/material.dart';

class DataCard extends StatefulWidget {
  const DataCard({
    super.key,
    required this.leading,
    required this.top,
    required this.bottom,
    this.isUnknown = false,
    this.unknownMessage,
    this.color,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
  });

  /// [Widget] which is located at start position of card
  final Widget leading;

  /// [Widget] which is located at upper side of card
  final Widget top;

  /// [Widget] which is located at lower side of card
  final Widget bottom;

  /// Background [Color] of this card
  final Color? color;

  /// Value of show [unknownMessage] or not
  final bool isUnknown;

  /// If [isUnknown] is `true`, show this rather than [top], [bottom] and [leading]
  final String? unknownMessage;

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
          child: IndexedStack(
            index: widget.isUnknown ? 0 : 1,
            children: [
              // 0
              Center(
                child: widget.unknownMessage == null ? const Icon(
                  Icons.question_mark_outlined,
                ) : Text(
                  widget.unknownMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              // 1
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.leading,
                  const SizedBox(width: 8,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.top,
                      widget.bottom,
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}