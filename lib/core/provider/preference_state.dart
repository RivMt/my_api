import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/preference_element.dart';
import 'package:my_api/core/provider/provider.dart' as core_provider;
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference.dart';
import 'package:my_api/core/model/preference_root.dart';

const String _tag = "Prefs";

/// Fetch preferences by root [preference]
void fetchPreferences(WidgetRef ref, StateNotifierProvider<PreferenceState, PreferenceRoot> preference) {
  ref.read(preference.notifier).fetch();
}

/// Pull preferences by root [preference]
void pullPreferences(WidgetRef ref, StateNotifierProvider<PreferenceState, PreferenceRoot> preference) {
  ref.read(preference.notifier).push();
} // TODO: ???

/// Set preferences by root [preference].
void setPreference(WidgetRef ref, StateNotifierProvider<PreferenceState, PreferenceRoot> preference, PreferenceRoot root) {
  ref.read(preference.notifier).set(root);
}

/// A root preference state notifier
class PreferenceState extends StateNotifier<PreferenceRoot> { // TODO: rename

  /// Initialize root preference from [ref], [section], and [init]
  PreferenceState(this.ref, this.section, Map<String, dynamic> init) : super(PreferenceRoot(section, init));

  final Ref ref;

  /// Section
  final String section; // TODO: getter
  
  /// Keys of children
  List<String> get keys => state.keys.toList(growable: false);

  /// Set [state] as [root]
  ///
  /// If [push] failed, [state] does not changed.
  Future<bool> set(PreferenceRoot root) async {
    final result = await push(root);
    if (result) {
      state = root.reallocate();
    }
    return result;
  }

  /// Pull root [Preference] from server
  ///
  /// Returns a value whether pull success.
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

  /// Push root [Preference] to server
  ///
  /// Push [state] if [root] is null. Returns a value whether push is success.
  Future<bool> push([PreferenceRoot? root]) async {
    final target = root ?? state;
    final owner = ref.watch(core_provider.currentUser).user.userId;
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
