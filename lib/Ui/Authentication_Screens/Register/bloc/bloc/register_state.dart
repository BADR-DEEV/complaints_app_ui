part of 'register_bloc.dart';

@immutable
sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

final class RegisterSuccess extends RegisterState {
  final RegisterResponse registerResponse;

  RegisterSuccess({required this.registerResponse});
}

final class RegisterFailure extends RegisterState {
  final String error;
  final RegisterResponse? registerResponse;

  RegisterFailure(this.registerResponse, {required this.error});
}
