import 'package:flutter/material.dart';
import 'package:my_api/src/core/api/api.dart';

/// Displays the application logo without handling user interaction.
class AppLogo extends StatelessWidget {
  /// Creates an application logo.
  const AppLogo({
    super.key,
    required this.iconName,
    required this.title,
    required this.isWide,
  });

  /// Asset path of the application icon.
  final String iconName;

  /// Application title.
  final String title;

  /// Whether to display the icon beside the title.
  final bool isWide;

  static const Map<AppMode, Color> labelColors = {
    AppMode.production: Colors.transparent,
    AppMode.dev: Color.fromARGB(255, 118, 255, 3),
    AppMode.demo: Color.fromARGB(255, 255, 3, 85),
    AppMode.edge: Color.fromARGB(255, 255, 46, 235),
    AppMode.test: Color.fromARGB(255, 255, 234, 46),
  };

  Widget buildTitle(BuildContext context) {
    final mode = ApiClient().mode;
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          title,
          maxLines: 1,
          semanticsLabel: title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Visibility(
          visible: mode != AppMode.production,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: labelColors[mode],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              mode.name.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = buildTitle(context);
    final Widget logo;
    if (isWide) {
      logo = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              iconName,
              width: 32,
              height: 32,
            ),
          ),
          const SizedBox(width: 8),
          title,
        ],
      );
    } else {
      logo = title;
    }

    return logo;
  }
}
