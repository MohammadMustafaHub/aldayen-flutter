import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aldayen/models/user.dart';

class UserState {
  final User? user;
  final bool isLoading;

  const UserState({
    this.user,
    this.isLoading = false,
  });

  bool get isAuthenticated => user != null;
  bool get isPhoneVerified => user?.isPhoneVerified ?? false;

  UserState copyWith({
    User? user,
    bool? isLoading,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState(isLoading: true));

  void setUser(User? user) => emit(state.copyWith(user: user, isLoading: false));

  void setLoading(bool value) =>
      emit(state.copyWith(isLoading: value));

  void logout() => emit(const UserState(user: null, isLoading: false));
}
