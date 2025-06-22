library my_api;

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// Superclass of all data mapping models
///
/// This class provides getter and setter react with [map].
abstract class Model {

  /// Maximum date
  static final DateTime maxDate = DateTime(2100, 12, 31);

  /// Minimum date
  static final DateTime minDate = DateTime(1970, 1, 1);

  /// Raw data of this object
  ///
  /// It is not possible to assign new Map because it is final. If you want to
  /// assign multiple values, use [Map.addAll].
  final Map<String, dynamic> map = {};

  /// Initialize class from given [map] (Optional)
  Model([Map<String, dynamic>? map]) {
    if (map != null) {
      this.map.addAll(map);
    }
  }

  /// Get `T?` value from [map] using [key]
  ///
  /// Returns [defaultValue] if [key] is not exists in [map].
  ///
  /// Use this method only for nullable value and must specify type [T].
  T? getValue<T>(String key, T? defaultValue) {
    // Check key is exist
    if (map.containsKey(key)) {
      return map[key];
    }
    // Return default value
    return defaultValue;
  }

  /// Set `T?` value of [key] as [value]
  void setValue<T>(String key, T? value) => map[key] = value;

  /// Get string from [map] using [key]
  ///
  /// If [key] is not in [map], returns [value].
  /// IF the value corresponding to [key] is `null`, returns [value].
  String getString(String key, String value) {
    if (!map.containsKey(key)) {
      return value;
    }
    if (map[key] == null) return value;
    return map[key].toString();
  }

  /// Set value of [key] as [value]
  ///
  /// Crop string if [maxLength] is defined.
  void setString(String key, String value, [int? maxLength]) {
    if (maxLength != null && value.length > maxLength) {
      value = value.substring(0, maxLength);
    }
    map[key] = value;
  }

  /// Gets integer from [map] using [key]
  ///
  /// If [key] is not in [map] or value of corresponding key is not parsable,
  /// or if the value corresponding to [key] is `null`,
  /// returns [value].
  int getInt(String key, int value) {
    if (!map.containsKey(key)) {
      return value;
    }
    if (map[key] is String) {
      try {
        return int.parse(map[key]);
      } on FormatException {
        return value;
      }
    }
    if (map[key] == null) return value;
    return map[key];
  }

  /// Sets value of [key] as [value]
  void setInt(String key, int value) => map[key] = value;

  /// Gets bool from [map] using [key]
  ///
  /// `1`, `true`, `True`, `TRUE` are considered as `true`.
  /// If [key] is not in [map], returns [value].
  /// If value of corresponding key is not parsable, returns [value].
  /// If the value corresponding to [key] is `null`, returns [value].
  bool getBool(String key, bool value) {
    if (!map.containsKey(key)) {
      return value;
    }
    if (map[key] is String) {
      final char = map[key].substring(0, 1).toLowerCase();
      return char == "t" || char == "1";
    }
    if (map[key] == null) return value;
    return map[key];
  }

  /// Sets value of [key] as [value]
  void setBool(String key, bool value) => map[key] = value;

  /// Get date from [key]
  ///
  /// Unlike [getDateTime], this method does not consider timezone.
  /// [value] is default value when [key] is not exist in [map].
  /// If the value corresponding to [key] is `null`, returns [value].
  DateTime getDate(String key, DateTime value) {
    if (!map.containsKey(key)) {
      return value;
    }
    if (map[key] is! String) return value;
    final utc = DateTime.parse(map[key]);
    return DateTime(utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second, utc.millisecond, utc.microsecond);
  }

  /// Set value of [key] as [date]
  ///
  /// Unlike [setDateTime], this method does not consider timezone.
  void setDate(String key, DateTime date) {
    final local = DateTime(date.year, date.month, date.day).add(date.timeZoneOffset).toUtc();
    map[key] = local.toIso8601String();
  }

  /// Get [DateTime] from [key]
  ///
  /// This method considers timezone and returns [DateTime] as local timezone.
  /// [value] is default value when [key] is not exist.
  /// If the value corresponding to [key] is `null`, returns [value].
  DateTime getDateTime(String key, DateTime value) {
    if (!map.containsKey(key)) {
      return value;
    }
    if (map[key] is! String) return value;
    return DateTime.parse(map[key]).toLocal();
  }

  /// Set value of [key] as [dateTime]
  ///
  /// This method considers timezone and shifts timezone of [dateTime] to UTC.
  /// The [dateTime] saved as ISO-8601 style string.
  void setDateTime(String key, DateTime dateTime) {
    map[key] = dateTime.toUtc().toIso8601String();
  }

  /// Get [List] from [key]
  ///
  /// [value] is default value when [key] is not exist or the type is not [List].
  /// This method assume that the value corresponding to [key] is `List<String>`.
  List<String> getList(String key, List<String> value) {
    if (!map.containsKey(key)) {
      return value;
    }
    if (map[key] is! List) return value;
    final result = <String>[];
    for (final item in map[key]) {
      result.add(item.toString());
    }
    return result;
  }

  /// Set value of [key] as [list]
  void setList(String key, List<String> list) {
    map[key] = list;
  }

  /// Get [Decimal] from [key]
  ///
  /// If [key] is not in [map], value of corresponding key is not parsable, or
  /// the value is not [String], return [value].
  Decimal getDecimal(String key, Decimal value) {
    if (!map.containsKey(key)) {
      return value;
    }
    if (map[key] is! String) return value;
    try {
      return Decimal.parse(map[key]);
    } on FormatException {
      return value;
    }
  }

  /// Set value of [key] as [decimal]
  void setDecimal(String key, Decimal decimal) {
    map[key] = decimal.toString();
  }

  /// Get [Color] from [key]
  Color getColor(String key, Color value) {
    if (!map.containsKey(key)) {
      return value;
    }
    if (map[key] is! int) return value;
    return Color(map[key]);
  }

  /// Set value of [key] as [color]
  void setColor(String key, Color color) {
    map[key] = color.toARGB32();
  }

  /// Check [other] is equivalent or not
  ///
  /// This method is distinct to operator `==`. `==` returns identical or not,
  /// however, this compares only representative value such as `uuid`.
  /// If this and [other] are equivalent, both objects must have same [representativeCode].
  bool isEquivalent(Model other);

  /// Hash code of representative value
  ///
  /// If `isEquivalent` is `true`, both objects must have same value.
  int get representativeCode;

  @override
  String toString() => map.toString();

  @override
  bool operator ==(Object other) {
    if (other is Model) {
      return map == other.map;
    }
    return super==(other);
  }

  @override
  int get hashCode => map.hashCode;
}

