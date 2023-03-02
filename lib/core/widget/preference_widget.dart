import 'package:flutter/material.dart';
import 'package:my_api/core.dart';

const double _defaultPadding = 8;

class PreferenceHeader extends StatelessWidget {
  const PreferenceHeader({
    super.key,
    this.title = "",
    this.trailing = const SizedBox(),
  });

  final String title;

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
              color: AppTheme.primary,
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class PreferenceTile extends StatelessWidget {

  const PreferenceTile({
    super.key,
    this.title = "",
    this.subtitle = "",
    this.trailing,
    this.onTap,
  });

  final String title;

  final String subtitle;

  final Widget? trailing;

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