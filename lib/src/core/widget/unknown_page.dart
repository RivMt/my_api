import 'package:flutter/material.dart';

/// Displays the fallback page for an unknown route.
class UnknownPage extends StatelessWidget {
  /// Creates an unknown-route page.
  const UnknownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Oops!"),
      ),
      body: const Center(
        child: Text("Unknown page"),
      ),
    );
  }
}
