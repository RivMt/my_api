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
    } else {
      throw UnsupportedError("Unsupported type of value: $value");
    }
    return "$type$value";
  }

  /// Decode string-style [data] to raw [value]
  static dynamic decode(final String data) {
    // If value is too short, return null
    if (data.length < 2) {
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

}