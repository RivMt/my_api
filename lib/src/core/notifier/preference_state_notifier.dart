import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/src/core/api.dart';
import 'package:my_api/src/core/log.dart';
import 'package:my_api/src/core/model/preference_element.dart';
import 'package:my_api/src/core/provider.dart' as core_provider;
import 'package:my_api/src/core/model/model_keys.dart';
import 'package:my_api/src/core/model/preference.dart';
import 'package:my_api/src/core/model/preference_root.dart';

const String _tag = "Prefs";

/// Pull preferences by root [preference]
void pullPreferences(WidgetRef ref, StateNotifierProvider<PreferenceStateNotifier, PreferenceRoot> preference) {
  ref.read(preference.notifier).pull();
}

/// Push preferences by root [preference]
void pushPreferences(WidgetRef ref, StateNotifierProvider<PreferenceStateNotifier, PreferenceRoot> preference) {
  ref.read(preference.notifier).push();
}

/// Set preferences by root [preference].
void setPreference(WidgetRef ref, StateNotifierProvider<PreferenceStateNotifier, PreferenceRoot> preference, PreferenceRoot root) {
  ref.read(preference.notifier).set(root);
}

/// A root preference state notifier
class PreferenceStateNotifier extends StateNotifier<PreferenceRoot> {

  /// Initialize root preference from [ref], [section], and [init]
  PreferenceStateNotifier(this.ref, String section, Map<String, dynamic> init) : super(PreferenceRoot(section, init));

  final Ref ref;

  /// Section
  String get section => state.section;
  
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
  Future<bool> pull() async {
    // Request
    final client = ApiClient();
    final response = await client.read<PreferenceElement>({
      ModelKeys.keySection: state.section,
    });
    if (!mounted) {
      Log.w(_tag, "State used after disposed");
      return false;
    }
    if (response.result != ApiResponseResult.success) {
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
      if (response.result != ApiResponseResult.success) {
        Log.e(_tag, "Failed to pull ${target.section} preferences: $map");
        return false;
      }
    }
    return true;
  }
}
