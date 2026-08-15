import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

/// Selects a month with previous and next controls.
class MonthPicker extends StatefulWidget {

  /// Currently selected month.
  final DateTime date;

  /// Called with the first day of the selected month.
  final void Function(DateTime) onDateChanged;

  /// Formats the selected month for display.
  final String Function(DateTime)? displayText;

  /// Creates a month picker.
  const MonthPicker({
    super.key,
    required this.date,
    this.displayText,
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

  String getMonthText(DateTime date) {
    if (widget.displayText != null) {
      return widget.displayText!(date);
    }
    final now = DateTime.now();
    if (date.year == now.year) {
      return DateFormat.MMM().format(date);
    }
    return DateFormat.yMMM().format(date);
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
        Text(getMonthText(widget.date)),
        // TODO: Add current month icon button
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => onButtonPressed(1),
        ),
      ],
    );
  }

}
