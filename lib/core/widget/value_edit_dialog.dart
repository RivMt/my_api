import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_api/core.dart';

class ValueEditDialog extends StatefulWidget {

  const ValueEditDialog({
    super.key,
    required this.title,
    this.value = 0.0,
    this.tick = 1.0,
    this.isDecimal = true,
    this.positiveButtonTitle = "OK",
    this.negativeButtonTitle = "Cancel",
  });

  final String title;

  final double tick;

  final double value;

  final bool isDecimal;

  final String positiveButtonTitle;

  final String negativeButtonTitle;

  @override
  State createState() => _ValueEditDialogState();
}

class _ValueEditDialogState extends State<ValueEditDialog> {

  final TextEditingController controller = TextEditingController();

  double value = 0.0;

  void appendValue(double delta) {
    value += delta;
    controller.text = value.toString();
  }

  void onValueChanged(String text) {
    value = double.parse(controller.text);
  }

  void close() {
    Navigator.pop(context, value);
  }

  @override
  void initState() {
    super.initState();
    value = widget.value;
    controller.text = value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: ScreenPlanner(context).dialogWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(
                decimal: widget.isDecimal,
              ),
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => appendValue(-widget.tick),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => appendValue(widget.tick),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter(RegExp(r"[\d.]"), allow: true),
              ],
              onChanged: onValueChanged,
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: close,
          style: Theme.of(context).textButtonTheme.style?.copyWith(
            overlayColor: AppTheme.textButtonOverlay(AppTheme.errorPrimary),
          ),
          child: Text(
            widget.negativeButtonTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.errorPrimary,
              inherit: true,
            ),
          ),
        ),
        TextButton(
          onPressed: close,
          child: Text(widget.positiveButtonTitle),
        ),
      ],
    );
  }
}