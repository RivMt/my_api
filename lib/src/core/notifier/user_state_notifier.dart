import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/src/core/api.dart';
import 'package:my_api/src/core/model/user.dart';


/// A user state notifier
class UserNotifier extends StateNotifier<UserState> {

  /// Initialize instance
  UserNotifier() : super(UserState(user: User.unknown));

  /// Login
  ///
  /// [onLogin] fires on login succeed.
  Future<void> login([Function()? onLogin]) async {
    state = state.copyWith(isLoading: true);
    final user = await ApiClient().login();
    state = state.copyWith(user: user, isLoading: false);
    if (onLogin != null) {
      onLogin();
    }
  }

  /// Logout
  ///
  /// [onLogout] fires on logout succeed.
  void logout([Function()? onLogout]) {
    ApiClient().logout();
    state = UserState(user: User.unknown);
    if (onLogout != null) {
      onLogout();
    }
  }
}


/// State of user
class UserState {

  /// Initialize
  ///
  /// Specify [User.unknown] when empty user required
  UserState({
    required this.user,
    this.isLoading = false,
  });

  /// Current [User]
  final User user;

  /// Whether currently login or logout
  final bool isLoading;

  /// Copy state instance with [user] and [isLoading]
  UserState copyWith({User? user, bool? isLoading}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}