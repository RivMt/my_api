import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/src/core/model/preference_root.dart';
import 'package:my_api/src/core/notifier/preference_state_notifier.dart';
import 'package:my_api/src/core/notifier/user_state_notifier.dart';

/// Initial value of core preference
final initCorePreference = <String, dynamic>{};

/// Core preference
final corePreferences = StateNotifierProvider<PreferenceStateNotifier, PreferenceRoot>((ref) {
  return PreferenceStateNotifier(ref, "core", initCorePreference);
});

/// Current user
final currentUser = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

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
  ref.read(currentUser.notifier).logout(onLogout);
}