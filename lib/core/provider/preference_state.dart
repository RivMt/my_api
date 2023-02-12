import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api/api_client.dart';
import 'package:my_api/core/api/api_core.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/preference.dart';

final preferenceProvider = StateNotifierProvider<PreferenceState, Map<String, Preference>>((ref) {
  return PreferenceState(ref);
});

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
  Future set(Preference pref) async {
    // Save in server first
    final response = await ApiClient().create<Preference>([pref.map]);
    if (response.result != ApiResultCode.success || response.data.length != 1) {
      // If failed, return failed response
      return;
    }
    // After success, apply to state
    state[pref.key] = pref;
    request();
  }

  /// Request [Preference]s filtered by [keys]
  Future request([Map<String, dynamic>? settings]) async {
    // Apply keys
    if (settings != null) {
      setDefaults(settings);
    }
    // Build condition
    final List<Map<String, dynamic>> condition = [];
    for (String key in keys) {
      condition.add({
        Preference.keyKey: key,
      });
    }
    // Request
    final client = ApiClient();
    final ApiResponse<List<Preference>> response = await client.read<Preference>(condition);
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to request $condition");
      clear();
      return;
    }
    // Apply
    for(Preference pref in response.data) {
      Log.i(_tag, "Request completed: $pref");
      state[pref.key] = pref;
    }
  }
}
