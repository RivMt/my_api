import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/model/preference_root.dart';
import 'package:my_api/core/model/user.dart';
import 'package:my_api/core/provider/preference_state.dart';
import 'package:my_api/core/provider/user_state_notifier.dart';

/// Initial value of core preference
final initCorePreference = <String, dynamic>{};

/// Core preference
final corePreferences = StateNotifierProvider<PreferenceState, PreferenceRoot>((ref) {
  return PreferenceState(ref, "core", initCorePreference);
});

/// Current user
final currentUser = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

/// Fires on current user changed
void setOnUserChanged(Function(User) listener) {
  final client = ApiClient();
  client.onUserChanges(listener);
}

/// Login from [ref]
///
/// [onLogin] fires on login succeed.
void login(WidgetRef ref, Function() onLogin) {
  ref.read(currentUser.notifier).login(onLogin);
}

/// Logout [currentUser] from [ref]
///
/// [onLogout] fires on logout succeed.
void logout(WidgetRef ref, Function() onLogout) {
  ref.read(currentUser.notifier).login(onLogout);
}