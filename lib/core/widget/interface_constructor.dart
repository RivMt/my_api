import 'package:flutter/material.dart';

abstract class InterfaceConstructor {

  /// Threshold ratio of width per height to check wide screen
  static const _standardRatio = 0.8;

  /// Value of additional panel is visible or not
  static bool isSidePanelVisible(BuildContext context) {
    return panelNumber(context) > 1;
  }

  /// Width of each panel
  static double panelWidth(BuildContext context) {
    return MediaQuery.of(context).size.width / panelNumber(context);
  }

  /// Calculate number of panels from [context]
  static int panelNumber(BuildContext context) {
    final double width, height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return (width >= _standardRatio * height) ? 2 : 1;
  }

}