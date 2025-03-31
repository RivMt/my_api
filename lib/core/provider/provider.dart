import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
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

void setOnUserChanged(Function(User) listener) {
  final client = ApiClient();
  client.onUserChanges(listener);
}

Future<void> login(WidgetRef ref, Function() onLogin) async {
  final user = await ApiClient().login();
  ref.read(currentUser.notifier).set(user);
  onLogin();
}