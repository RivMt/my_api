library my_api;

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// Superclass of all API models.
abstract class Model {

  /// Maximum date
  static final DateTime maxDate = DateTime(2100, 12, 31);

  /// Minimum date
  static final DateTime minDate = DateTime(1970, 1, 1);

  /// Raw data of this object
  final Map<String, dynamic> map = {};

  /// Constructor
  Model([Map<String, dynamic>? map]) {
    if (map != null) {
      this.map.addAll(map);
    }
  }

  /// Get value of [map] using [key]
  ///
  /// **DO NOT** call this directly. Use several property variables to access.
  /// When [key] is not included in [map], return [defaultValue].
  getValue(String key, dynamic defaultValue) {
    // Check key is exist
    if (map.containsKey(key)) {
      return map[key];
    }
    // Return default value
    return defaultValue;
  }

  /// Get date from [key]
  ///
  /// [value] is default value when [key] is not exist in [map].
  DateTime getDate(String key, DateTime value) {
    if (!map.containsKey(key)) {
      return value;
    }
    assert(map[key] is String);
    final utc = DateTime.parse(map[key]);
    return DateTime(utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second, utc.millisecond, utc.microsecond);
  }

  /// Set date [value] to [key]
  void setDate(String key, DateTime value) {
    final local = DateTime(value.year, value.month, value.day).add(value.timeZoneOffset).toUtc();
    map[key] = local.toIso8601String();
  }

  /// Get [DateTime] from [key]
  ///
  /// [value] is default value when [key] is not exist.
  DateTime getDateTime(String key, DateTime value) {
    if (!map.containsKey(key)) {
      return value;
    }
    assert(map[key] is String);
    return DateTime.parse(map[key]).toLocal();
  }

  /// Set [value] to [key]
  void setDateTime(String key, DateTime value) {
    map[key] = value.toUtc().toIso8601String();
  }

  /// Get [List] from [key]
  ///
  /// [value] is default value when [key] is not exist.
  /// Raw [String] value will be split by [pattern]. Default value of [pattern]
  /// is ` `.
  ///
  /// ```dart
  /// // Map
  /// {
  ///   "key": "abc def"
  /// }
  /// list = getList("key", []);
  /// // Result = ["abc", "def"]
  /// ```
  List<String> getList(String key, List<String> value, [String pattern = " "]) {
    if (!map.containsKey(key)) {
      return value;
    }
    assert(map[key] is String);
    return (map[key] as String).split(pattern);
  }

  /// Set [List] to [key]
  ///
  /// [separator] is letter of joining [value]
  ///
  /// ```dart
  /// setList("key", ["abc", "def"]);
  /// // Map
  /// {
  ///   "key": "abc def"
  /// }
  /// ```
  void setList(String key, List<String> value, [String separator = " "]) {
    map[key] = value.join(separator);
  }

  /// Get [Decimal] from [key]
  Decimal getDecimal(String key, Decimal value) {
    if (!map.containsKey(key)) {
      return value;
    }
    assert(map[key] is String);
    return Decimal.parse(map[key]);
  }

  /// Set [Decimal] to [key]
  void setDecimal(String key, Decimal value) {
    map[key] = value.toString();
  }

  /// Get [Color] from [key]
  Color getColor(String key, Color color) {
    if (!map.containsKey(key)) {
      return color;
    }
    assert(map[key] is int);
    return Color(map[key]);
  }

  /// Set [Color] to [key]
  void setColor(String key, Color color) {
    map[key] = color.value;
  }

  /// Check [other] is equivalent or not
  ///
  /// This method is distinct to operator `==`. `==` is compare all variables,
  /// however, this compares only representative value such as `uuid`.
  bool isEquivalent(Model other);

  @override
  String toString() => map.toString();
}

