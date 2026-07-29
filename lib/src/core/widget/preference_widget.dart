import 'package:flutter/material.dart';

const double _defaultPadding = 8;

/// Displays a preference-section title and optional trailing control.
class PreferenceHeader extends StatelessWidget {
  /// Creates a preference header.
  const PreferenceHeader({
    super.key,
    this.title = "",
    this.trailing = const SizedBox(),
  });

  /// Section title.
  final String title;

  /// Control displayed after the title.
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_defaultPadding*2, _defaultPadding*2, _defaultPadding*2, _defaultPadding/2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

/// Displays one tappable preference row.
class PreferenceTile extends StatelessWidget {

  /// Creates a preference tile.
  const PreferenceTile({
    super.key,
    this.title = "",
    this.subtitle = "",
    this.trailing,
    this.onTap,
  });

  /// Preference name.
  final String title;

  /// Current value or supporting text.
  final String subtitle;

  /// Optional control displayed at the end of the row.
  final Widget? trailing;

  /// Called when the tile is tapped.
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

}
