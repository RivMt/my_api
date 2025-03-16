import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference.dart';
import 'package:my_api/core/provider/model_state.dart';
import 'package:my_api/core/provider/preference_state.dart';

final preferences = StateNotifierProvider<PreferenceState, Map<String, Preference>>((ref) {
  return PreferenceState(ref);
});

void syncPreferences(WidgetRef ref, [Map<String, dynamic>? init]) {
  ref.read(preferences.notifier).sync(init);
}

T? getPreference<T>(ref, String key) {
  return ref.watch(preferences)[key]?.value;
}

Future<bool> setPreference(ref, String key, dynamic value) {
  return ref.read(preferences.notifier).set(Preference.fromKV(
    {},
    key: key,
    value: value,
  ));
}

Future<bool> deletePreference(ref, String key) {
  return ref.read(preferences.notifier).delete(key);
}

final minPriorityFilter = StateNotifierProvider<ModelState<int>, int>((ref) {
  return ModelState<int>(ref, 0);
});

final maxPriorityFilter = StateNotifierProvider<ModelState<int>, int>((ref) {
  return ModelState<int>(ref, 1000);
});

final sortFilter = StateNotifierProvider<ModelState<String>, String>((ref) {
  return ModelState<String>(ref, ModelKeys.keyUuid);
});