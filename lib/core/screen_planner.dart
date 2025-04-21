import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// A class for screen layout
class ScreenPlanner {

  /// Threshold ratio of width per height to check wide screen
  static const _standardRatio = 0.8;

  /// Ratio of dialog width per panel width
  static const _dialogWidthRadio = 0.9;

  /// Private instance for singleton pattern
  static final ScreenPlanner _instance = ScreenPlanner._();

  /// Private constructor for singleton pattern
  ScreenPlanner._();

  /// Factory constructor for singleton pattern
  factory ScreenPlanner(BuildContext context) {
    _context = context;
    return _instance;
  }

  /// [BuildContext] of screen [_instance] planning to.
  ///
  /// It is normally not `null`.
  static BuildContext? _context;

  /// Value of additional panel is visible or not
  bool get isSidePanelVisible => panelNumber > 1;

  /// Width of each panel
  double get panelWidth => MediaQuery.of(_context!).size.width / panelNumber;

  /// Calculate number of panels based on [context]
  int get panelNumber {
    final double width, height;
    width = MediaQuery.of(_context!).size.width;
    height = MediaQuery.of(_context!).size.height;
    return (width >= _standardRatio * height) ? 2 : 1;
  }

  /// Width of dialog
  double get dialogWidth => panelWidth * _dialogWidthRadio;

  /// Height of dialog
  double get dialogHeight => MediaQuery.of(_context!).size.height * _dialogWidthRadio;

  /// Value of the platform is desktop compatible or not
  bool get isDesktop {
    if (kIsWeb) {
      return panelNumber >= 2;
    }
    return Platform.isMacOS
        || Platform.isWindows
        || Platform.isLinux;
  }

}