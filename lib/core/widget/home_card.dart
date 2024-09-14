import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_api/core/model/stateful_data.dart';
import 'package:my_api/core/widget/message_box.dart';

class HomeCard extends StatelessWidget {

  const HomeCard({
    super.key,
    required this.title,
    this.subtitle = "",
    required this.state,
    this.children = const [],
  });

  final String title;

  final String subtitle;

  final StatefulDataState state;

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
            Align(
              alignment: Alignment.topLeft,
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
              index: state.code,
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