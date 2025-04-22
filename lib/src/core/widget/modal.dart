import 'package:flutter/material.dart';
import 'package:my_api/src/core/theme.dart';

class Modal extends StatefulWidget {

  const Modal({
    super.key,
    this.ready = true,
    this.title = "",
    this.positiveButtonTitle = "",
    this.negativeButtonTitle = "",
    required this.onPositiveButtonPressed,
    required this.onNegativeButtonPressed,
    required this.child,
  });

  final bool ready;

  final String title, positiveButtonTitle, negativeButtonTitle;

  final Future<bool> Function() onPositiveButtonPressed;

  final Future<bool> Function() onNegativeButtonPressed;

  final Widget child;

  @override
  State createState() => _ModalState();

}

class _ModalState extends State<Modal> {

  /// Value of sent [editing] and waiting for response
  bool _progressing = false;

  /// Value of sent [editing] and waiting for response
  ///
  /// This is wrapper of [_progressing]. When setting this, [setState] called
  /// automatically
  bool get progressing => _progressing;

  set progressing(bool value) {
    setState(() {
      _progressing = value;
    });
  }

  /// Triggers on positive button pressed
  void onPos() async {
    progressing = true;
    final result = await widget.onPositiveButtonPressed();
    if (!result) {
      progressing = false;
    }
    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }

  /// Triggers on negative button pressed
  void onNeg() async {
    progressing = true;
    final result = await widget.onNegativeButtonPressed();
    if (!result) {
      progressing = false;
    }
    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            ModalHeader(
              disabled: progressing || !widget.ready,
              headerTitle: widget.title,
              positiveButtonTitle: widget.positiveButtonTitle,
              negativeButtonTitle: widget.negativeButtonTitle,
              onPositiveButtonPressed: progressing ? null : onPos,
              onNegativeButtonPressed: progressing ? null : onNeg,
            ),
            // Child
            Padding(
              padding: const EdgeInsets.all(8),
              child: widget.child,
            ),
            // Progress
            Visibility(
              visible: progressing,
              child: const LinearProgressIndicator(value: null,),
            ),
          ],
        ),
      ),
    );
  }
}

class ModalHeader extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
            onPressed: disabled ? null : onNegativeButtonPressed,
            style: Theme.of(context).textButtonTheme.style?.copyWith(
              overlayColor: AppTheme.textButtonOverlay(AppTheme.errorPrimary),
            ),
            child: Text(
              negativeButtonTitle,
              style: disabled ? null : Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.errorPrimary,
                inherit: true,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              headerTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: disabled ? null : onPositiveButtonPressed,
            child: Text(positiveButtonTitle),
          ),
        ],
      ),
    );
  }
}