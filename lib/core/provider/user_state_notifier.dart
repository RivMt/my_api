import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/model/user.dart';

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState(user: User.unknown));

  Future<void> login([Function()? onLogin]) async {
    state = state.copyWith(isLoading: true);
    final user = await ApiClient().login();
    state = state.copyWith(user: user, isLoading: false);
    if (onLogin != null) {
      onLogin();
    }
  }

  void logout([Function()? onLogout]) {
    ApiClient().logout();
    state = UserState(user: User.unknown);
    if (onLogout != null) {
      onLogout();
    }
  }
}

class UserState {

  UserState({
    required this.user,
    this.isLoading = false,
  });

  final User user;

  final bool isLoading;

  UserState copyWith({User? user, bool? isLoading}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}