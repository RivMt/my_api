import 'package:flutter/material.dart';
import 'package:my_api/src/core/api/api.dart';
import 'package:my_api/src/core/widget/app_logo.dart';
import 'package:my_api/src/core/widget/app_version_modal.dart';

/// Displays an interactive application title.
class AppTitle extends StatelessWidget {
  /// Creates an interactive application title.
  const AppTitle({
    super.key,
    required this.iconName,
    required this.title,
    required this.isWide,
    this.onTap,
  });

  /// Asset path of the application icon.
  final String iconName;

  /// Application title.
  final String title;

  /// Whether to display the icon beside the title.
  final bool isWide;

  /// Called when the title is tapped.
  ///
  /// When null, displays [AppVersionModal]. Use [AppLogo] when interaction is
  /// not needed.
  final VoidCallback? onTap;

  void _showVersionModal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AppVersionModal(
        iconName: iconName,
        title: title,
        channel: ApiClient().mode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => _showVersionModal(context),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AppLogo(
          iconName: iconName,
          title: title,
          isWide: isWide,
        ),
      ),
    );
  }
}
