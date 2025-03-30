import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference.dart';
import 'package:my_api/core/model/preference_element.dart';

class PreferenceRoot extends Preference {

  PreferenceRoot(this.section) : super();

  /// Section of this preference
  final String section;

  /// Apply from received data
  void apply(List<Map<String, String>> raw) {
    for(Map<String, String> map in raw) {
      addChild(PreferenceElement.fromMap(this, map));
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
      final map = <String, String>{};
      map[ModelKeys.keySection] = section;
      map[ModelKeys.keyOwner] = owner;
      map[ModelKeys.keyKey] = child.key;
      map[ModelKeys.keyValue] = child.rawValue;
      result.add(map);
    }
    return result;
  }

}