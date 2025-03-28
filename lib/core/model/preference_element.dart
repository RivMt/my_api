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
        set(PreferenceElement(
          parent: this,
          key: key,
          value: value[key]!,
        ));
      }
      return;
    }
    this.value = value;
  }

  /// Construct from JSON map
  PreferenceElement.fromMap(this.parent, Map<String, dynamic> map) : super.fromMap(map) {
    key = map[ModelKeys.keyKey]!;
    final data = Preference.decode(map[ModelKeys.keyValue]!);
    if (data is Map<String, dynamic>) {
      for(String key in data.keys) {
        set(PreferenceElement(
          parent: this,
          key: key,
          value: Preference.decode(data[key]!),
        ));
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

  final Preference parent;

  /// Key of preference
  String key = "";

  /// Value of preference (Read-only)
  T? get value => _value;

  set value(T? v) {
    if (!isLeaf) {
      throw UnsupportedError("Assigning value to parent preference is not supported");
    }
    _value = v;
  }

  T? _value;

  /// Check this node is leaf or not
  bool get isLeaf => children.isEmpty;

  /// Raw value of preference
  String get rawValue => Preference.encode(isLeaf ? value : map);

  @override
  void set(PreferenceElement element) {
    if (value != null) {
      throw UnsupportedError("Appending child to leaf node preference is not supported");
    }
    super.set(element);
  }

  @override
  String toString() => "[Pref] $key = ${isLeaf ? value : map}";

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