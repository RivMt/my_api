import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference.dart';

class PreferenceElement<T> extends Preference {

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

  /// Construct from JSON map
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

  /// Construct from raw value like below
  ///
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

  Preference parent;

  /// Key of preference
  String key = "";

  /// Value of preference
  T? get value => _value;

  set value(T? v) {
    if (isStem) {
      throw UnsupportedError("Assigning value to parent preference is not supported: $key");
    }
    _value = v;
  }

  T? _value;

  /// Check this node is leaf or not
  bool get isLeaf => value != null;

  /// Check this node is stem or not
  bool get isStem => children.isNotEmpty;

  /// Raw value of preference
  String get rawValue => Preference.encode(isLeaf ? value : map);

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

class PreferenceDummy extends Preference {

  static final PreferenceDummy _instance = PreferenceDummy._();

  factory PreferenceDummy() => _instance;

  PreferenceDummy._();

}