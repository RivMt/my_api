import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/model/preference_root.dart';
import 'package:my_api/core/model/user.dart';
import 'package:my_api/core/provider/preference_state.dart';
import 'package:my_api/core/provider/user_state_notifier.dart';

final initCorePreference = <String, dynamic>{};

final corePreferences = StateNotifierProvider<PreferenceState, PreferenceRoot>((ref) {
  return PreferenceState(ref, "core", initCorePreference);
});

final currentUser = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

void setOnUserChanged(Function(User) listener) {
  final client = ApiClient();
  client.onUserChanges(listener);
}

void login(WidgetRef ref, Function() onLogin) {
  ref.read(currentUser.notifier).login(onLogin);
}

void logout(WidgetRef ref, Function() onLogout) {
  ref.read(currentUser.notifier).login(onLogout);
}