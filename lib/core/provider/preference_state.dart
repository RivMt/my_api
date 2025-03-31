import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/preference_element.dart';
import 'package:my_api/core/provider/provider.dart' as core_provider;
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference.dart';
import 'package:my_api/core/model/preference_root.dart';

const String _tag = "Prefs";

void fetchPreferences(WidgetRef ref, StateNotifierProvider<PreferenceState, PreferenceRoot> preference) {
  ref.read(preference.notifier).fetch();
}

void pullPreferences(WidgetRef ref, StateNotifierProvider<PreferenceState, PreferenceRoot> preference) {
  ref.read(preference.notifier).push();
}

void setPreference(WidgetRef ref, StateNotifierProvider<PreferenceState, PreferenceRoot> preference, PreferenceRoot root) {
  ref.read(preference.notifier).set(root);
}

class PreferenceState extends StateNotifier<PreferenceRoot> {

  PreferenceState(this.ref, this.section, Map<String, dynamic> init) : super(PreferenceRoot(section, init));

  final Ref ref;

  final String section;
  
  /// Keys
  List<String> get keys => state.keys.toList(growable: false);

  /// Set preference as [root]
  Future<bool> set(PreferenceRoot root) async {
    final result = await push(root);
    if (result) {
      state = root.reallocate();
    }
    return result;
  }

  /// Fetch [Preference]s from server
  Future<bool> fetch() async {
    // Request
    final client = ApiClient();
    final response = await client.read<PreferenceElement>({
      ModelKeys.keySection: state.section,
    });
    if (!mounted) {
      Log.w(_tag, "State used after disposed");
      return false;
    }
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to fetch ${state.section} preferences");
      return false;
    }
    // Apply
    PreferenceRoot root = PreferenceRoot(section, state.map);
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
      final response = await client.update<PreferenceElement>(map);
      if (response.result != ApiResultCode.success) {
        Log.e(_tag, "Failed to pull ${target.section} preferences: $map");
        return false;
      }
    }
    return true;
  }
}
