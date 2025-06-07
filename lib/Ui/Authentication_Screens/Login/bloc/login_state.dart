part of 'login_bloc.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final LoginResponse loginResponse;

  LoginSuccess({required this.loginResponse});
}

final class LoginFailure extends LoginState {
  final String error;
  final LoginResponse? loginResponse;

  LoginFailure(this.loginResponse, {required this.error});
}
