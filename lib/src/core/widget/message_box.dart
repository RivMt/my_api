import 'package:flutter/material.dart';

/// Displays a centered icon and message.
class MessageBox extends StatelessWidget {
  /// Creates a message box.
  const MessageBox({
    super.key,
    required this.icon,
    required this.message,
  });

  /// Icon displayed above the message.
  final IconData icon;

  /// Message text.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          child: Icon(icon),
        ),
        Text(
          message,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
