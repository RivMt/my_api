import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {

  const AppLogo({
    super.key,
    required this.iconName,
    required this.title,
    required this.isWide,
  });

  final String iconName;

  final String title;

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final title = Text(this.title,
      maxLines: 1,
      semanticsLabel: this.title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
    if (!isWide) {
      return title;
    }
    return Row(
      children: [
        Visibility(
          visible: isWide,
          child: Container(
            alignment: Alignment.center,
            child: Image.asset(iconName,
              width: 32,
              height: 32,
            ),
          ),
        ),
        const SizedBox(width: 8),
        title,
      ],
    );
  }
}