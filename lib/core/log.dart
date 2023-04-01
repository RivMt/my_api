library my_api;

import 'dart:developer';

enum LogLevel {
  error(4, "E", "Error"),
  warning(3, "W", "Warning"),
  debug(2, "D", "Debug"),
  info(1, "I", "Info"),
  verbose(0, "V", "Verbose");

  final int level;

  final String letter;

  final String code;

  const LogLevel(this.level, this.letter, this.code);

  @override
  String toString() => code;
}

class Log {

  static LogLevel level = LogLevel.verbose;

  static void _print(LogLevel level, String color, String? tag, Object? msg, [Object? e, StackTrace? s]) {
    // Do not log its level is lower than level
    if (level.level < Log.level.level) {
      return;
    }
    log(
      "$color$msg\x1B[0m",
      name: "${level.letter}/${tag ?? ""}",
      time: DateTime.now(),
      level: level.level,
      error: e,
      stackTrace: s,
    );
  }

  static void e([String? tag, Object? msg, Object? e, StackTrace? s]) {
    _print(LogLevel.error, "\x1B[31m", tag, msg, e, s);
  }

  static void w([String? tag, Object? msg, Object? e, StackTrace? s]) {
    _print(LogLevel.warning, "\x1B[33m", tag, msg, e, s);
  }

  static void d([String? tag, Object? msg, Object? e, StackTrace? s]) {
    _print(LogLevel.debug, "\x1B[32m", tag, msg, e, s);
  }

  static void i([String? tag, Object? msg, Object? e, StackTrace? s]) {
    _print(LogLevel.info, "\x1B[36m", tag, msg, e, s);
  }

  static void v([String? tag, Object? msg, Object? e, StackTrace? s]) {
    _print(LogLevel.verbose, "", tag, msg, e, s);
  }

}