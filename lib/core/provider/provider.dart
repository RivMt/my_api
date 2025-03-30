import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/model/preference_root.dart';
import 'package:my_api/core/model/user.dart';
import 'package:my_api/core/provider/model_state.dart';
import 'package:my_api/core/provider/preference_state.dart';

final initCorePreference = <String, dynamic>{};

final corePreferences = StateNotifierProvider<PreferenceState, PreferenceRoot>((ref) {
  return PreferenceState(ref, "core", initCorePreference);
});

final currentUser = StateNotifierProvider<ModelState<User>, User>((ref) {
  return ModelState<User>(ref, User.unknown);
});

void login(WidgetRef ref, User user) {
  ref.read(currentUser.notifier).set(user);
}