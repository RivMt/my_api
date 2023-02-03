import 'package:flutter/material.dart';

abstract class InterfaceConstructor {

  static const _standardRatio = 0.7;

  static int panelNumber(BuildContext context) {
    final double width, height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return (width >= _standardRatio * height) ? 2 : 1;
  }

}