import 'package:flutter/material.dart';

/// Hide material glow effect when scroll is out of range.
class NoGlowScrollBehavior extends ScrollBehavior {

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}