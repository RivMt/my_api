import 'package:flutter/material.dart';
import 'package:my_api/src/core/model/stateful_data.dart';
import 'package:my_api/src/core/widget/message_box.dart';

/// Displays home content for its loading, ready, or error state.
class HomeCard extends StatelessWidget {

  /// Creates a state-aware home card.
  const HomeCard({
    super.key,
    required this.title,
    this.subtitle = "",
    required this.state,
    this.children = const [],
  });

  /// Primary heading.
  final String title;

  /// Optional secondary heading.
  final String subtitle;

  /// State that selects the visible card content.
  final StatefulDataState state;

  /// Content shown when [state] is ready.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: title != "",
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Visibility(
                    visible: subtitle != "",
                    child: Text(
                      subtitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            IndexedStack(
              index: state.code.level,
              children: [
                // Ready
                Column(
                  children: children,
                ),
                // Loading
                const Center(
                  child: CircularProgressIndicator(),
                ),
                // Error
                Align(
                  alignment: Alignment.center,
                  child: MessageBox(
                    icon: Icons.error_outline,
                    message: state.message,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
