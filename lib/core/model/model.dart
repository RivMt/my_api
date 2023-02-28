library my_api;

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

abstract class Model {

  static const String keyId = "id";
  static const String keyPid = "pid";
  static const String keyLastUsed = "last_used";
  static const String keyOwner = "owner_id";
  static const String keyEditors = "editors_id";
  static const String keyViewers = "viewers_id";
  static const String keyDescriptions = "descriptions";
  static const String keyDeleted = "deleted";

  /// Raw data of this object
  Map<String, dynamic> map = {};

  /// Constructor
  Model([this.map = const {}]);

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
    assert(map[key] is int);
    final utc = DateTime.fromMillisecondsSinceEpoch(map[key], isUtc: true);
    return DateTime(utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second, utc.millisecond, utc.microsecond);
  }

  /// Set date [value] to [key]
  void setDate(String key, DateTime value) {
    final local = DateTime(value.year, value.month, value.day).add(value.timeZoneOffset).toUtc();
    map[key] = local.millisecondsSinceEpoch;
  }

  /// Get [DateTime] from [key]
  ///
  /// [value] is default value when [key] is not exist.
  DateTime getDateTime(String key, DateTime value) {
    if (!map.containsKey(key)) {
      return value;
    }
    assert(map[key] is int);
    return DateTime.fromMillisecondsSinceEpoch(map[key]);
  }

  /// Set [value] to [key]
  void setDateTime(String key, DateTime value) {
    map[key] = value.millisecondsSinceEpoch;
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

  /// ID (Read-only)
  int get id => getValue(keyId, -1);

  /// PID (Read-only)
  int get pid => getValue(keyPid, -1);

  /// [DateTime] of lastly used (Read-only)
  ///
  /// There is no problem when edit it manually, however, server will be update
  /// this when request update. Therefore, it is useless editing [lastUsed]
  /// property.
  DateTime get lastUsed => getDateTime(keyLastUsed, DateTime.fromMillisecondsSinceEpoch(0));

  /// UID of owner
  String get owner => getValue(keyOwner, "");

  set owner(String id) => throw UnimplementedError();

  /// List of editor UID
  List<String> get editors => getList(keyEditors, []);

  set editors(List<String> list) => setList(keyEditors, list);

  /// List of viewers UID
  List<String> get viewers => getList(keyViewers, []);

  set viewers(List<String> list) => setList(keyViewers, list);

  /// Descriptions of this object
  String get descriptions => getValue(keyDescriptions, "");

  set descriptions(String desc) => map[keyDescriptions] = desc;

  /// Is this object deleted or not
  bool get deleted => getValue(keyDeleted, false);

  set deleted(bool value) => map[keyDeleted] = value;

  @override
  String toString() => map.toString();

  @override
  bool operator ==(Object other) {
    if (other is Model) {
      return pid == other.pid;
    }
    return super==(other);
  }

  @override
  int get hashCode {
    return toString().hashCode;
  }
}

