import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_api/src/core/app_mode.dart';
import 'package:my_api/src/core/widget/app_logo.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Displays the application logo, version, and release channel.
class AppVersionModal extends StatefulWidget {
  /// Creates an application version modal.
  const AppVersionModal({
    super.key,
    required this.iconName,
    required this.title,
    required this.channel,
  });

  /// Asset path of the application icon.
  final String iconName;

  /// Application title.
  final String title;

  /// Application release channel.
  final AppMode channel;

  @override
  State<AppVersionModal> createState() => _AppVersionModalState();
}

class _AppVersionModalState extends State<AppVersionModal> {
  final versionRollingRelease = "0.0.0";

  final versionNameRollingRelease = "Rolling Release";

  final versionNameUnknown = "Unknown";

  final versionNameHead = "HEAD";

  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  String _getVersionName(PackageInfo packageInfo) {
    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;
    if (version == versionRollingRelease) {
      if (buildNumber.isEmpty) {
        return versionNameHead;
      }
      return '$versionNameRollingRelease #$buildNumber';
    }
    if (buildNumber.isEmpty) {
      return version;
    }
    return '$version+$buildNumber';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: AppLogo(
        iconName: widget.iconName,
        title: widget.title,
        isWide: true,
      ),
      content: FutureBuilder<PackageInfo>(
        future: _packageInfo,
        builder: (context, snapshot) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Version',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
                        child: Text(
                          snapshot.hasData
                              ? _getVersionName(snapshot.data!)
                              : versionNameUnknown,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Channel',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
                        child: Text(widget.channel.name),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('msgCommonDisclaimer'.tr()),
              if (widget.channel == AppMode.demo) ...[
                const SizedBox(height: 8),
                Text('msgDemoDisclaimer'.tr()),
              ] else if (widget.channel != AppMode.production) ...[
                const SizedBox(height: 8),
                Text('msgDevDisclaimer'.tr()),
              ],
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
