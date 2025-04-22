import 'dart:collection';

import 'package:decimal/decimal.dart';
import 'package:my_api/src/core/model/preference_element.dart';

/// A preference class
///
/// Preferences are consist of multiple preference instances. Its structure is
/// like tree. A leaf node can store a single value, however, a stem node can
/// store multiple children nodes.
abstract class Preference<T> {

  /// API endpoint path
  static const String endpoint = "api/core/preferences";

  /// Escape letter of control character
  static const String tokenEscape = "\\";

  /// Type indicator of [int]
  static const String tokenInteger = "I";

  /// Type indicator of [String]
  static const String tokenString = "S";

  /// Type indicator of [Decimal]
  static const String tokenDecimal = "D";

  /// Type indicator of [double]
  static const String tokenDouble = "d";

  /// Type indicator of [bool]
  static const String tokenBoolean = "B";

  /// Type indicator of [List]
  static const String tokenList = "L";

  /// Separator of each list item
  static const String tokenListSeparator = ",";

  /// Opening character of list
  static const String tokenListOpener = "[";

  /// Closing character of list
  static const String tokenListCloser = "]";

  /// Type indicator of [Map]
  static const String tokenMap = "M";

  /// Connecting character of map
  static const String tokenMapConnector = ":";

  /// Separator of each map key-value item
  static const String tokenMapSeparator = ";";

  /// Opening character of map
  static const String tokenMapOpener = "{";

  /// Closing character of map
  static const String tokenMapCloser = "}";

  /// Type indicator of [DateTime]
  static const String tokenDateTime = "Z";

  /// List of characters which should be escaped
  static const List<String> escapeCandidates = [  // TODO: Consider rename
    tokenListSeparator,
    tokenListOpener,
    tokenListCloser,
    tokenMapConnector,
    tokenMapSeparator,
    tokenMapOpener,
    tokenMapCloser,
  ];

  /// Encode raw [value] to string-style data
  static String encode(dynamic value) {  // TODO: Refactor
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
        final Map<String, dynamic> map = {};
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

  /// Check the [value] is processable map
  static bool checkMap(value) {
    return (value is Map<String, dynamic>)
        || (value is HashMap<String, dynamic>)
        || (value is SplayTreeMap<String, dynamic>)
        || (value is LinkedHashMap<String, dynamic>);
  }

  /// Initialize empty preference
  Preference();

  /// Initialize new instance from [map]
  Preference.fromMap(Map<String, dynamic> map);

  /// Children of current preference
  final Map<String, PreferenceElement> _children = {};

  /// List of children preference
  Iterable<PreferenceElement> get children => _children.values;

  /// List of children preference keys
  Iterable<String> get keys => _children.keys;

  /// Whether there is a child which its key is [key]
  bool containsKey(String key) => _children.containsKey(key);

  /// Set child [value] as [key]
  ///
  /// It is recommended to specify type
  void set<V>(String key, V value) => setChild(PreferenceElement<V>(
    parent: this,
    key: key,
    value: value,
  ));

  /// Set [element] as child
  ///
  /// If there is a child which has same key, it will be replaced by [element].
  void setChild(PreferenceElement element) {
    element.parent = this;
    _children[element.key] = element;
  }

  /// Replace children by [elements]
  void setChildren(Iterable<PreferenceElement> elements) {
    for(PreferenceElement element in elements) {
      setChild(element);
    }
  }

  /// Get child by [key]
  ///
  /// If [key] is not contained, set new child with [key], [value].
  /// It is recommend to specify type because sometimes new child has been created
  /// by above description.
  PreferenceElement get<V>(String key, V value) {
    if (!containsKey(key)) {
      set<V>(key, value);
    }
    return _children[key]!;
  }

  /// Remove child by [key]
  ///
  /// If it does not contains [key], return `null`.
  PreferenceElement? remove(String key) {
    if (!containsKey(key)) {
      return null;
    }
    return _children.remove(key);
  }

  /// Converts this instance as map
  ///
  /// The results contains key and value of its children.
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