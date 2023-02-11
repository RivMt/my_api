import 'package:flutter/material.dart';

class MessageBox extends StatelessWidget {
  const MessageBox({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
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
      ),
    );
  }
}