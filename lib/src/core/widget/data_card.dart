import 'package:flutter/material.dart';

/// Displays interactive data with leading, primary, and secondary content.
class DataCard extends StatefulWidget {
  /// Creates an interactive data card.
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

  /// Content displayed at the start of the card.
  final Widget leading;

  /// Primary content displayed above [bottom].
  final Widget top;

  /// Secondary content displayed below [top].
  final Widget bottom;

  /// Card background color.
  final Color? color;

  /// Whether to replace the card content with [unknownMessage].
  final bool isUnknown;

  /// Message displayed for unknown data.
  final String? unknownMessage;

  /// Pointer callbacks for the card.
  final Function()? onTap, onDoubleTap, onLongPress;

  /// Called when the pointer enters or leaves the card.
  final Function(bool)? onHover;

  @override
  State createState() => _DataCardState();
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.top,
                        widget.bottom,
                      ],
                    ),
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
