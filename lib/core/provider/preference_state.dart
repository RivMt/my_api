import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/provider/provider.dart' as core_provider;
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference.dart';
import 'package:my_api/core/model/preference_root.dart';

const String _tag = "Prefs";

void fetchPreferences(WidgetRef ref, StateNotifierProvider<PreferenceState, PreferenceRoot> preference) {
  ref.read(preference.notifier).fetch();
}

void pullPreferences(WidgetRef ref, StateNotifierProvider<PreferenceState, PreferenceRoot> preference, [Map<String, dynamic>? init]) {
  if (init != null) {
    ref.read(preference.notifier).init(init);
  }
  ref.read(preference.notifier).push();
}

void setPreference(WidgetRef ref, StateNotifierProvider<PreferenceState, PreferenceRoot> preference, PreferenceRoot root) {
  ref.read(preference.notifier).set(root);
}

class PreferenceState extends StateNotifier<PreferenceRoot> {

  PreferenceState(this.ref, this.section) : super(PreferenceRoot(section));

  final Ref ref;

  final String section;

  /// Clear state
  void clear() => state = PreferenceRoot(section);
  
  /// Keys
  List<String> get keys => state.keys.toList(growable: false);

  /// Apple default settings
  void init(Map<String, dynamic> settings) {
    PreferenceRoot root = PreferenceRoot(section);
    root.addAll(settings);
    state = root;
  }

  /// Set preference as [root]
  Future<bool> set(PreferenceRoot root) async {
    final result = await push(root);
    if (result) {
      state = root;
    }
    return result;
  }

  /// Fetch [Preference]s from server
  Future<bool> fetch() async {
    final owner = ref.watch(core_provider.currentUser).userId;
    // Request
    final client = ApiClient();
    final response = await client.send<Map<String, String>>(HttpMethod.get, Preference.endpoint, null, ApiQuery({
      ModelKeys.keySection: state.section,
      ModelKeys.keyOwner: owner,
    }));
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to fetch ${state.section} preferences");
      clear();
      return false;
    }
    // Apply
    PreferenceRoot root = PreferenceRoot(section);
    root.apply(response.data);
    state = root;
    return true;
  }

  /// Push [Preference]s to server
  ///
  /// Push [state] if [root] is null
  Future<bool> push([PreferenceRoot? root]) async {
    final target = root ?? state;
    final owner = ref.watch(core_provider.currentUser).userId;
    final data = target.rawChildren(owner);
    final client = ApiClient();
    for(Map<String, String> map in data) {
      final response = await client.send<Map<String, dynamic>>(
          HttpMethod.put, Preference.endpoint, map);
      if (response.result != ApiResultCode.success) {
        Log.e(_tag, "Failed to pull ${target.section} preferences");
        clear();
        return false;
      }
    }
    return true;
  }
}
