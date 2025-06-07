part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}


final class LoginUserEvent extends LoginEvent {
  final LoginRequest loginRequest;

  LoginUserEvent({required this.loginRequest});
}