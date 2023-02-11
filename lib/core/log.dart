library my_api;

import 'dart:io';

import 'package:flutter/foundation.dart';

enum LogLevel {
  error,
  warning,
  debug,
  info,
  verbose,
}

class Log {

  static LogLevel level = LogLevel.verbose;

  static void _print(LogLevel level, String color, String? tag, Object? msg) {
    // Do not log its level is lower than level
    if (level.index > Log.level.index) {
      return;
    }
    if (kIsWeb) {
      if (kDebugMode) {
        print("[${level.name.substring(0, 1).toUpperCase()}/$tag] $msg");
      }
    } else {
      // Set color
      stdout.write(color);
      // Print tag
      if (tag == null) {
        stdout.write("[${level.name}] ");
      } else {
        stdout.write("[${level.name.substring(0, 1).toUpperCase()}/$tag] ");
      }
      // Print msg
      stdout.write("${msg ?? ""}");
      // Reset color and print newline
      stdout.write("\x1B[0m\n");
    }
  }

  static void e([String? tag, Object? msg]) {
    _print(LogLevel.error, "\x1B[31m", tag, msg);
  }

  static void w([String? tag, Object? msg]) {
    _print(LogLevel.warning, "\x1B[33m", tag, msg);
  }

  static void d([String? tag, Object? msg]) {
    _print(LogLevel.debug, "\x1B[32m", tag, msg);
  }

  static void i([String? tag, Object? msg]) {
    _print(LogLevel.info, "\x1B[36m", tag, msg);
  }

  static void v([String? tag, Object? msg]) {
    _print(LogLevel.verbose, "", tag, msg);
  }

}