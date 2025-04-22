import 'package:my_api/src/core/log.dart';
import 'package:my_api/src/core/model/model_keys.dart';
import 'package:my_api/src/core/model/preference.dart';
import 'package:my_api/src/core/model/preference_element.dart';

const String _tag = "PreferenceRoot";

/// A root preference
///
/// This cannot become a child node
class PreferenceRoot extends Preference {

  PreferenceRoot(this.section, Map<String, dynamic> init) : super() {
    addAll(map);
  }

  /// Section of this preference
  final String section;

  /// Apply [raw] as [children]
  void apply(List<PreferenceElement> raw) {
    for(PreferenceElement element in raw) {
      setChild(element);
    }
  }

  /// Add [map] as [children]
  void addAll(Map<String, dynamic> map) {
    for(String key in map.keys) {
      set(key, map[key]);
    }
  }

  /// Raw value of preference
  String get rawValue => Preference.encode(map);

  /// List of raw value of children
  ///
  /// Throws [UnsupportedError] when [children] includes a child which has unsupported value.
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

  /// Returns new root for state notifying
  ///
  /// Use this there is a necessary to reallocate.
  PreferenceRoot reallocate() {
    final PreferenceRoot root = PreferenceRoot(section, {});
    root.setChildren(children);
    return root;
  }

}