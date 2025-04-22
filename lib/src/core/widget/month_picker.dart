import 'package:flutter/material.dart';

class MonthPicker extends StatefulWidget {

  final DateTime date;

  final void Function(DateTime) onDateChanged;

  final String Function(DateTime) displayText;

  const MonthPicker({
    super.key,
    required this.date,
    required this.displayText,
    required this.onDateChanged,
  });

  @override
  State createState() => _MonthPickerState();

}

class _MonthPickerState extends State<MonthPicker> {

  void onButtonPressed(int delta) {
    final changed = DateTime(widget.date.year, widget.date.month + delta, 1);
    return widget.onDateChanged(changed);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onButtonPressed(-1),
        ),
        Text(widget.displayText(widget.date)),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => onButtonPressed(1),
        ),
      ],
    );
  }

}