library my_api;

import 'dart:math' as math;

import 'package:easy_logger/easy_logger.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';


/// A log system inspired by Android logcat
class Log {

  /// Minimum level of log
  static Level minimumLevel = Level.trace;

  /// Logger instance
  static final Logger _logger = Logger(
    printer: LogPrinter(),
  );

  /// Print log message with [level], [tag], [msg], error [e], and stack trace [s]
  ///
  /// If [level] is lower than current level, ignores printing.
  static void _print(Level level, String? tag, Object? msg, [Object? e, StackTrace? s]) {
    final letter = level.name.substring(0, 1).toUpperCase();
    _logger.log(
      level,
      "[$letter/$tag] $msg",
      error: e,
      stackTrace: s,
    );
  }

  /// Print error message
  static void e([String? tag, Object? msg, Object? e, StackTrace? s]) {
    _print(Level.error, tag, msg, e, s);
  }

  /// Print warning message
  static void w([String? tag, Object? msg, Object? e, StackTrace? s]) {
    _print(Level.warning, tag, msg, e, s);
  }

  /// Print debug message
  static void d([String? tag, Object? msg, Object? e, StackTrace? s]) {
    _print(Level.debug, tag, msg, e, s);
  }

  /// Print info message
  static void i([String? tag, Object? msg, Object? e, StackTrace? s]) {
    _print(Level.info, tag, msg, e, s);
  }

  /// Print verbose message
  static void v([String? tag, Object? msg, Object? e, StackTrace? s]) {
    _print(Level.trace, tag, msg, e, s);
  }

  /// [EasyLogPrinter] for EasyLocalization dependency
  static final EasyLogPrinter easyLogger = (Object object, {
    String? name,
    StackTrace? stackTrace,
    LevelMessages? level,
  }) {
    final lv = easyLoggerLevelMap[level] ?? Level.trace;
    _print(lv, name, object, null, stackTrace);
  } as EasyLogPrinter;

  /// Map of [EasyLogger]'s [LevelMessages] to [Level]
  static final easyLoggerLevelMap = {
    LevelMessages.info: Level.info,
    LevelMessages.debug: Level.debug,
    LevelMessages.warning: Level.warning,
    LevelMessages.error: Level.error,
  };

}


/// A log printer
class LogPrinter extends PrettyPrinter {

  /// Pattern of date time
  static const String datetimePattern = "yyyy-MM-dd hh:mm:ss SSS";

  /// Date time formatter
  static final DateFormat dateFormat = DateFormat(datetimePattern, "en-US");

  /// Initialize
  LogPrinter() : super(
    methodCount: 0,
    colors: true,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.none,
    noBoxingByDefault: true,
    levelColors: {
      Level.error: const AnsiColor.fg(1),
      Level.warning: const AnsiColor.fg(3),
      Level.debug: const AnsiColor.fg(2),
      Level.info: const AnsiColor.fg(6),
    },
  );

  /// Returns [AnsiColor] of corresponding [level]
  AnsiColor _getLevelColor(Level level) {
    AnsiColor? color;
    if (colors) {
      color = levelColors?[level] ?? PrettyPrinter.defaultLevelColors[level];
    }
    return color ?? const AnsiColor.none();
  }

  @override
  List<String> log(LogEvent event) {
    final buffer = <String>[];
    final color = _getLevelColor(event.level);
    final datetime = dateFormat.format(event.time.toLocal());
    final msg = event.message;
    buffer.add(color("$datetime $msg"));
    if (event.error != null) {
      final lines = event.error.toString().split("\n").map((line) => color(line)).toList();
      buffer.addAll(lines.take(errorMethodCount ?? lines.length));
    }
    if (event.stackTrace != null) {
      final lines = event.stackTrace.toString().split("\n");
      final paddings = (math.log(lines.length) / math.log(10)).toInt() + 1;
      final numberFormat = NumberFormat(List.filled(paddings, "0").join(), "en-US");
      for(int i=0; i < lines.length; i++) {
        final line = lines[i];
        if (line.isEmpty) {
          continue;
        }
        buffer.add("- #${numberFormat.format(stackTraceBeginIndex+i)} $line");
      }
    }
    return buffer;
  }
}

