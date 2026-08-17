import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_api/src/core/app_mode.dart';
import 'package:my_api/src/core/screen_planner.dart';
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
    this.disclaimer,
  });

  /// Asset path of the application icon.
  final String iconName;

  /// Application title.
  final String title;

  /// Application release channel.
  final AppMode channel;

  /// Application-specific disclaimer displayed below the version details.
  final Widget? disclaimer;

  @override
  State<AppVersionModal> createState() => _AppVersionModalState();
}

class _AppVersionModalState extends State<AppVersionModal> {
  static const buildDateRaw = String.fromEnvironment(
    'BUILD_DATE',
    defaultValue: dateSnapshot,
  );

  static const dateSnapshot = "Snapshot";

  static const versionRollingRelease = "0.0.0";

  static const versionNameRollingRelease = "Rolling Release";

  static const versionNameUnknown = "Unknown";

  static const versionNameHead = "HEAD";

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
    final format = DateFormat.yMd();
    final buildDate = (buildDateRaw != dateSnapshot) ? format.format(DateTime.parse(buildDateRaw)) : dateSnapshot;
    return AlertDialog(
      scrollable: true,
      constraints: BoxConstraints(
        maxWidth: ScreenPlanner(context).panelWidth,
      ),
      title: Row(
        children: [
          Expanded(
            child: AppLogo(
              iconName: widget.iconName,
              title: widget.title,
              isWide: true,
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
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
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Build Date',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
                        child: Text(buildDate),
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.disclaimer != null) ...[
                const SizedBox(height: 16),
                widget.disclaimer!,
              ],
            ],
          );
        },
      ),
    );
  }
}
