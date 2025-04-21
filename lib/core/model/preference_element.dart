import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference.dart';
import 'package:my_api/core/model/preference_root.dart';

/// An element of preference
///
/// This can become a stem and node node except root. Use [PreferenceRoot] as root preference.
/// If empty preference is required, use [PreferenceDummy].
class PreferenceElement<T> extends Preference {

  /// Initialize preference from [parent], [key] and [value]
  ///
  /// If [value] is map, [value] is assigned as [children].
  /// Otherwise, it is assigned as [value].
  PreferenceElement({
    required this.parent,
    required String key,
    required T value,
  }) : super() {
    this.key = key;
    if (value is Map<String, dynamic>) {
      for(String key in value.keys) {
        set(key, value[key]!);
      }
      return;
    }
    this.value = value;
  }

  /// Initialize preference from [map]
  ///
  /// The [map] is assumed as JSON.
  PreferenceElement.fromMap(this.parent, Map<String, dynamic> map) : super.fromMap(map) {
    key = map[ModelKeys.keyPreferenceKey]!;
    final data = Preference.decode(map[ModelKeys.keyPreferenceValue]!);
    if (data is Map<String, dynamic>) {
      for(String key in data.keys) {
        set(key, data[key]!);
      }
      return;
    }
    value = data;
  }

  /// Initialize preference from [parent], [key], and [rawValue]
  ///
  /// It is distinct to default constructor, because only the [String] can be
  /// a [rawValue]. And [rawValue] is decoded by [Preference.decode].
  /// ```json
  /// {
  ///   "key1": 0,
  ///   "key2": "test"
  /// }
  /// ```
  PreferenceElement.fromRawValue({
    required Preference parent,
    required String key,
    required String rawValue,
  }) : this(
    parent: parent,
    key: key,
    value: Preference.decode(rawValue),
  );

  /// A parent instance of current preference
  Preference parent;

  /// Key of this preference
  String key = "";

  /// Value of this preference
  ///
  /// It is `null` if this node is a stem node. However, `null` value does not
  /// mean this instance is stem node always. Sometimes, not initialized instance
  /// can have `null` value.
  /// If there is necessary to check it is stem or not, use [isStem].
  T? get value => _value;

  set value(T? v) {
    if (isStem) {
      throw UnsupportedError("Assigning value to parent preference is not supported: $key");
    }
    _value = v;
  }

  /// Value
  T? _value;

  /// Whether this node is leaf
  ///
  /// If it is `true`, [value] is `null` because every leaf node has non-null value.
  bool get isLeaf => value != null;

  /// Whether this node is stem
  ///
  /// If it is `true`, this preference has at least one child.
  bool get isStem => children.isNotEmpty;

  /// Raw value of preference
  ///
  /// If this is leaf node, returns raw value of [value], otherwise, [map].
  String get rawValue => Preference.encode(isLeaf ? value : map);

  /// Set [element] as child
  ///
  /// Throws [UnsupportedError] when trying to set child to leaf node.
  @override
  void setChild(PreferenceElement element) {
    if (isLeaf) {
      throw UnsupportedError("Appending child to leaf node preference is not supported: $key = $value");
    }
    super.setChild(element);
  }

  @override
  String toString() => isLeaf ? "$key = $value" : key;

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is PreferenceElement) {
      return key == other.key;
    }
    return super==(other);
  }

}


/// A dummy preference
///
/// It is singleton instance. It should be used as empty preference temporarily.
class PreferenceDummy extends Preference {

  static final PreferenceDummy _instance = PreferenceDummy._();

  factory PreferenceDummy() => _instance;

  PreferenceDummy._();

}