import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference.dart';

const String _tag = "Prefs";

class PreferenceState extends StateNotifier<Map<String, Preference>> {

  PreferenceState(this.ref) : super(<String, Preference>{});

  final Ref ref;

  /// Clear state
  void clear() => state = {};
  
  /// Keys
  List<String> get keys => state.keys.toList(growable: false);

  /// Set [state] as [settings]
  void setDefaults(Map<String, dynamic> settings) {
    for(String key in settings.keys) {
      if (!state.containsKey(key)) {
        state[key] = Preference.fromKV({}, key: key, value: settings[key]);
      }
    }
  }

  /// Set value about key
  ///
  /// It request to save [pref] to server. If it failed, don't save to local
  /// storage. It only save [pref] to local storage when request succeed.
  ///
  /// This process is required to idealize local and server.
  Future<bool> set(Preference pref) async {
    // Save in server first
    var response = await ApiClient().create<Preference>([pref.map]);
    if (response.result != ApiResultCode.success || response.data.length != 1) {
      // If failed, return false
      Log.w(_tag, "Preference update/creation failed: $pref");
      return false;
    }
    // After success, apply to state
    state[pref.key] = pref;
    return true;
  }

  /// Delete preference as [key]
  Future<bool> delete(String key) async {
    // Try from server first
    final response = await ApiClient().delete([{
      ModelKeys.keyKey: key,
    }]);
    if (response.result != ApiResultCode.success || response.data.length != 1) {
      return false;
    }
    // After success, remove from state
    state.remove(key);
    return true;
  }

  /// Request [Preference]s filtered by [keys]
  Future<bool> sync([Map<String, dynamic>? settings]) async {
    // Apply keys
    if (settings != null) {
      setDefaults(settings);
    }
    // Build condition
    final List<Map<String, dynamic>> condition = [];
    for (String key in keys) {
      condition.add({
        ModelKeys.keyKey: key,
      });
    }
    // Request
    final client = ApiClient();
    final ApiResponse<List<Preference>> response = await client.read<Preference>(condition);
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to request $condition");
      clear();
      return false;
    }
    // Apply
    for(Preference pref in response.data) {
      Log.i(_tag, "Request completed: $pref");
      state[pref.key] = pref;
    }
    return true;
  }
}
