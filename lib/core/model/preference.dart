import 'package:decimal/decimal.dart';
import 'package:my_api/core/model/preference_element.dart';

abstract class Preference<T> {

  static const String endpoint = "api/core/preferences";

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
    final String type = data.substring(0, 1);
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

  Preference();

  Preference.fromMap(Map<String, dynamic> map);

  /// Child preferences
  final Map<String, PreferenceElement> _children = {};

  /// Child preferences
  Iterable<PreferenceElement> get children => _children.values;

  /// List of child preferences keys
  Iterable<String> get keys => _children.keys;

  /// Check preference contains [key]
  bool containsKey(String key) => _children.containsKey(key);

  /// Set child
  void set(PreferenceElement element) => _children[element.key] = element;

  /// Get child by [key]
  ///
  /// If [key] is not contained, set new [PreferenceElement] with [key], [value]
  PreferenceElement get<V>(String key, V value) {
    if (!containsKey(key)) {
      set(PreferenceElement<V>(
        parent: this,
        key: key,
        value: value,
      ));
    }
    return _children[key]!;
  }

  /// Convert [children] to map
  Map<String, dynamic> get map {
    final Map<String, dynamic> map = {};
    for(PreferenceElement child in children) {
      map[child.key] = (child.isLeaf) ? child.value : child.map;
    }
    return map;
  }

  @override
  String toString() => "[Pref] $_children";

}