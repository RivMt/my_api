import 'package:decimal/decimal.dart';
import 'package:my_api/core.dart';

class Preference extends Model {

  static final Preference unknown = Preference({});

  static const String tokenEscape = "\\";

  static const String tokenInteger = "I";

  static const String tokenString = "S";

  static const String tokenDecimal = "D";

  static const String tokenDouble = "d";

  static const String tokenBoolean = "B";

  static const String tokenList = "L";

  static const String tokenListSeparator = ",";

  static const String tokenListOpener = "[";

  static const String tokenListCloser = "]";

  static const String tokenMap = "M";

  static const String tokenMapConnector = ":";

  static const String tokenMapSeparator = ";";

  static const String tokenMapOpener = "{";

  static const String tokenMapCloser = "}";

  static const String tokenDateTime = "Z";

  static const List<String> escapeCandidates = [
    tokenListSeparator,
    tokenListOpener,
    tokenListCloser,
    tokenMapConnector,
    tokenMapSeparator,
    tokenMapOpener,
    tokenMapCloser,
  ];

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
      type = tokenInteger;
    } else if (value is String) {
      type = tokenString;
      // Escape
      for(String candidate in escapeCandidates) {
        str = str.replaceAll(candidate, "\\$candidate");
      }
    } else if (value is Decimal) {
      type = tokenDecimal;
    } else if (value is double) {
      type = tokenDouble;
    } else if (value is bool) {
      type = tokenBoolean;
    } else if (value is List) {
      type = tokenList;
      final s = [];
      for (dynamic item in value) {
        s.add(encode(item));
      }
      str = tokenListOpener + s.join(tokenListSeparator) + tokenListCloser;
    } else if (value is Map) {
      type = tokenMap;
      final s = [];
      for (dynamic key in value.keys) {
        s.add("${encode(key)}$tokenMapConnector${encode(value[key])}");
      }
      str = tokenMapOpener + s.join(tokenMapSeparator) + tokenMapCloser;
    } else if (value is DateTime) {
      type = tokenDateTime;
      str = value.toUtc().millisecondsSinceEpoch.toString();
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
      case tokenInteger: // Integer
        return int.parse(data.substring(1, data.length));
      case tokenString: // String
        return data.substring(1, data.length).replaceAll(tokenEscape, "");
      case tokenDecimal: // Decimal
        return Decimal.parse(data.substring(1, data.length));
      case tokenDouble: // Double
        return double.parse(data.substring(1, data.length));
      case tokenBoolean: // Boolean
        return data.substring(1,2).toLowerCase() == "t";
      case tokenList: // List
        assert(data[1] == tokenListOpener);
        assert(data[data.length-1] == tokenListCloser);
        final primitives = data.substring(2, data.length-1);
        final List list = [];
        int cursor = 0, depth = 0, anchor = 0;
        while(cursor < primitives.length) {
          int r = cursor+1 == primitives.length ? 1 : -1; // Split when value is bigger than -1
          if (primitives[cursor] == tokenEscape) {
            cursor++;
            r = cursor >= primitives.length-1 ? 1 : -1;
          } else if (primitives[cursor] == tokenListOpener) {
            depth++;
          } else if (primitives[cursor] == tokenListCloser) {
            depth--;
          } else if (primitives[cursor] == tokenListSeparator) {
            r = depth == 0 ? 0 : -1;
          }
          if (r >= 0) {
            final p = primitives.substring(anchor, cursor + r);
            list.add(decode(p));
            anchor = cursor+r+1;
          }
          cursor++;
        }
        return list;
      case tokenMap:
        assert(data[1] == tokenMapOpener);
        assert(data[data.length-1] == tokenMapCloser);
        final primitives = data.substring(2, data.length-1);
        final Map map = {};
        int cursor = 0, depth = 0, anchor = 0, connector = -1;
        while(cursor < primitives.length) {
          int r = cursor+1 == primitives.length ? 1 : -1; // Split when value is bigger than -1
          if (primitives[cursor] == tokenEscape) {
            cursor++;
            r = cursor >= primitives.length-1 ? 1 : -1;
          } else if (primitives[cursor] == tokenMapOpener) {
            depth++;
          } else if (primitives[cursor] == tokenMapCloser) {
            depth--;
          } else if (primitives[cursor] == tokenMapSeparator) {
            r = depth == 0 ? 0 : -1;
          } else if (primitives[cursor] == tokenMapConnector) {
            if (depth == 0) {
              connector = cursor;
            }
          }
          if (r >= 0) {
            final key = primitives.substring(anchor, connector);
            final value = primitives.substring(connector+1, cursor + r);
            map[decode(key)] = decode(value);
            anchor = cursor+r+1;
          }
          cursor++;
        }
        return map;
      case tokenDateTime:
        return DateTime.fromMillisecondsSinceEpoch(int.parse(data.substring(1, data.length)), isUtc: true).toLocal();
      default:
        return null;
    }
  }

  /// Section of this preference located
  String get section => getValue(ModelKeys.keySection, "");

  set section(String value) => map[ModelKeys.keySection] = value;

  /// Key of preference
  String get key => getValue(ModelKeys.keyKey, "");

  set key(String key) => map[ModelKeys.keyKey] = key;

  /// Value of preference
  dynamic get value => decode(getValue(ModelKeys.keyValue, ""));

  set value(dynamic value) => map[ModelKeys.keyValue] = encode(value);

  /// Raw value of preference
  String get rawValue => getValue(ModelKeys.keyValue, "");

  @override
  String toString() => "(Pref) $key = $rawValue";

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is Preference) {
      return (key == other.key && value == other.value) || (key == other.key);
    }
    return super==(other);
  }

}