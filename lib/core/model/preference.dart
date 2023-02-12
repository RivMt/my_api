import 'package:decimal/decimal.dart';
import 'package:my_api/core.dart';

class Preference extends Model {

  static const String keyOwnerId = "owner_id";

  static const String keySection = "section";

  static const String keyKey = "key";

  static const String keyValue = "value";

  static final Preference unknown = Preference({});

  Preference(super.map);

  Preference.fromKV(super.map, {
    required String key,
    required dynamic value,
  }) {
    this.key = key;
    this.value = value;
  }

  /// Encode raw [value] to string-style data
  static String encode(dynamic value) {
    late String type;
    String str = value.toString();
    if (value is int) {
      type = "I";
    } else if (value is String) {
      type = "S";
    } else if (value is Decimal) {
      type = "D";
    } else if (value is double) {
      type = "d";
    } else if (value is bool) {
      type = "B";
    } else if (value is List) {
      type = "L";
      final s = [];
      for (dynamic item in value) {
        s.add(encode(item));
      }
      str = s.join(",");
    } else if (value is Map) {
      type = "M";
      final s = [];
      for(dynamic key in value.keys) {
        s.add("${encode(key)}:${encode(value[key])}");
      }
      str = s.join(",");
    } else {
      throw UnsupportedError("Unsupported type of value: $value");
    }
    return "$type$str";
  }

  /// Decode string-style [data] to raw [value]
  ///
  /// **I** is [int], **S** is [String], **D** is [Decimal], **d** is [double],
  /// **B** is [bool], and **L** is [List]. It does not support nested list.
  static dynamic decode(final String data) {
    // If value is too short, return null
    if (data.isEmpty) {
      return null;
    }
    // Check type
    final String type = data.substring(0,1);
    switch(type) {
      case "I": // Integer
        return int.parse(data.substring(1, data.length));
      case "S": // String
        return data.substring(1, data.length);
      case "D": // Decimal
        return Decimal.parse(data.substring(1, data.length));
      case "d": // Double
        return double.parse(data.substring(1, data.length));
      case "B": // Boolean
        return data.substring(1,2).toLowerCase() == "t";
      case "L": // List
        final primitives = data.substring(1, data.length).split(",");
        final List list = [];
        for(String p in primitives) {
          list.add(decode(p));
        }
        return list;
      case "M":
        if (data.substring(1, data.length) == "") {
          return {};
        }
        final primitives = data.substring(1, data.length).split(",");
        final Map map = {};
        for(String p in primitives) {
          final kv = p.split(":");
          assert(kv.length == 2);
          map[decode(kv[0])] = decode(kv[1]);
        }
        return map;
      default:
        return null;
    }
  }

  /// Section of this preference located
  String get section => getValue(keySection, "");

  set section(String value) => map[keySection] = value;

  /// Key of preference
  String get key => getValue(keyKey, "");

  set key(String key) => map[keyKey] = key;

  /// Value of preference
  dynamic get value => decode(getValue(keyValue, ""));

  set value(dynamic value) => map[keyValue] = encode(value);

  /// Raw value of preference
  String get rawValue => getValue(keyValue, "");

  @override
  String toString() => "(Pref) $key = $rawValue";

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object? other) {
    if (other is Preference) {
      return (key == other.key && value == other.value) || (key == other.key);
    }
    return super==(other);
  }

}