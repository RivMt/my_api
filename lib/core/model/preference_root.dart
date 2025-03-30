import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference.dart';
import 'package:my_api/core/model/preference_element.dart';

const String _tag = "PreferenceRoot";

class PreferenceRoot extends Preference {

  PreferenceRoot(this.section, Map<String, dynamic> init) : super() {
    addAll(map);
  }

  /// Section of this preference
  final String section;

  /// Apply from received data
  void apply(List<PreferenceElement> raw) {
    for(PreferenceElement element in raw) {
      setChild(element);
    }
  }

  /// Add all from map
  void addAll(Map<String, dynamic> map) {
    for(String key in map.keys) {
      set(key, map[key]);
    }
  }

  /// Raw value of preference
  String get rawValue => Preference.encode(map);

  /// List of children raw
  List<Map<String, String>> rawChildren(String owner) {
    final result = <Map<String, String>>[];
    for(PreferenceElement child in children) {
      try {
        final map = <String, String>{};
        map[ModelKeys.keySection] = section;
        map[ModelKeys.keyOwner] = owner;
        map[ModelKeys.keyPreferenceKey] = child.key;
        map[ModelKeys.keyPreferenceValue] = child.rawValue;
        result.add(map);
      } on UnsupportedError {
        Log.e(_tag, "${child.key} skipped due to unsupported value: ${child.value}");
      }
    }
    return result;
  }

  /// Return new root for state notifying
  PreferenceRoot reallocate() {
    final PreferenceRoot root = PreferenceRoot(section, {});
    root.setChildren(children);
    return root;
  }

}