part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}


final class RegisterUserEvent extends RegisterEvent {
  final RegisterRequest registerRequest;

  RegisterUserEvent({required this.registerRequest});
}