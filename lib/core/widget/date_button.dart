import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DateButton extends StatelessWidget {
  const DateButton({
    super.key,
    required this.date,
    this.onTap,
  });

  final DateTime date;

  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
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