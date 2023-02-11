import 'package:flutter/material.dart';
import 'package:my_api/core/theme.dart';

class ModalHeader extends StatefulWidget {
  const ModalHeader({
    super.key,
    this.disabled = false,
    this.headerTitle = "",
    this.negativeButtonTitle = "",
    this.positiveButtonTitle = "",
    this.onNegativeButtonPressed,
    this.onPositiveButtonPressed,
  });

  final bool disabled;

  final String headerTitle;

  final String negativeButtonTitle;

  final String positiveButtonTitle;

  final Function()? onNegativeButtonPressed;

  final Function()? onPositiveButtonPressed;

  @override
  _ModalHeaderState createState() => _ModalHeaderState();
}

class _ModalHeaderState extends State<ModalHeader> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
            onPressed: widget.disabled ? null : widget.onNegativeButtonPressed,
            style: Theme.of(context).textButtonTheme.style?.copyWith(
              overlayColor: AppTheme.textButtonOverlay(AppTheme.errorPrimary),
            ),
            child: Text(
              widget.negativeButtonTitle,
              style: widget.disabled ? null : Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.errorPrimary,
                inherit: true,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              widget.headerTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: widget.disabled ? null : widget.onPositiveButtonPressed,
            child: Text(widget.positiveButtonTitle),
          ),
        ],
      ),
    );
  }
}