import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_api/core.dart';

/// Edits a numeric value with direct input and step controls.
class ValueEditModal extends StatefulWidget {

  /// Creates a numeric value editor.
  const ValueEditModal({
    super.key,
    required this.title,
    this.value = 0.0,
    this.tick = 1.0,
    this.isDecimal = true,
    this.positiveButtonTitle = "OK",
    this.negativeButtonTitle = "Cancel",
  });

  /// Modal title.
  final String title;

  /// Amount added or removed by the step controls.
  final double tick;

  /// Initial value.
  final double value;

  /// Whether decimal input is accepted.
  final bool isDecimal;

  /// Confirmation button label.
  final String positiveButtonTitle;

  /// Cancellation button label.
  final String negativeButtonTitle;

  @override
  State createState() => _ValueEditModalState();
}

class _ValueEditModalState extends State<ValueEditModal> {

  final TextEditingController controller = TextEditingController();

  double value = 0.0;

  void appendValue(double delta) {
    value += delta;
    controller.text = value.toString();
  }

  void onValueChanged(String text) {
    value = double.parse(controller.text);
  }

  void close([bool isCancel = false]) {
    Navigator.pop(context, isCancel ? widget.value : value);
  }

  @override
  void initState() {
    super.initState();
    value = widget.value;
    controller.text = value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModalHeader(
              headerTitle: widget.title,
              positiveButtonTitle: widget.positiveButtonTitle,
              negativeButtonTitle: widget.negativeButtonTitle,
              onPositiveButtonPressed: close,
              onNegativeButtonPressed: close,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
