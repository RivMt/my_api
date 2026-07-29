import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_api/src/core/model/model.dart';

/// Displays a date and opens a date picker when tapped.
class DateButton extends StatelessWidget {
  /// Creates a date selection button.
  const DateButton({
    super.key,
    required this.date,
    this.onChanged,
  });

  /// Currently displayed date.
  final DateTime date;

  /// Called after a date is selected.
  final Function(DateTime)? onChanged;

  /// Opens the date picker using [base] as its initial value.
  Future<DateTime> showDatePickDialog(BuildContext context, DateTime base) async {
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: Model.maxDate,
    );
    return result ?? base;
  }

  /// Opens the picker and reports the selected date.
  void onDateButtonPressed(BuildContext context) async {
    final result = await showDatePickDialog(context, date);
    if (onChanged != null) {
      onChanged!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onDateButtonPressed(context),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              DateFormat.yMd().format(date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8,),
            Icon(
              Icons.calendar_today_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
