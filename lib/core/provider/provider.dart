import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference.dart';
import 'package:my_api/core/model/user.dart';
import 'package:my_api/core/provider/model_state.dart';
import 'package:my_api/core/provider/preference_state.dart';

final preferences = StateNotifierProvider<PreferenceState, Map<String, Preference>>((ref) {
  return PreferenceState(ref);
});

void syncPreferences(WidgetRef ref, [Map<String, dynamic>? init]) {
  ref.read(preferences.notifier).sync(init);
}

Future<bool> setPreference(WidgetRef ref, Preference pref) async {
  return await ref.read(preferences.notifier).set(pref);
}

Future<bool> deletePreference(WidgetRef ref, String key) async {
  return await ref.read(preferences.notifier).delete(key);
}

final minPriorityFilter = StateNotifierProvider<ModelState<int>, int>((ref) {
  return ModelState<int>(ref, 0);
});

final maxPriorityFilter = StateNotifierProvider<ModelState<int>, int>((ref) {
  return ModelState<int>(ref, 1000);
});

final sortFilter = StateNotifierProvider<ModelState<String>, String>((ref) {
  return ModelState<String>(ref, ModelKeys.keyPid);
});