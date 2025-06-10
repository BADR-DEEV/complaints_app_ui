import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:complaintsapp/AppClient/Models/RegisterDtos/register_req.dart';
import 'package:complaintsapp/AppClient/Models/RegisterDtos/register_res.dart';
import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:complaintsapp/AppClient/Services/_urlApi.dart';
import 'package:complaintsapp/AppClient/Services/api_manager.dart';
import 'package:meta/meta.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterUserEvent>(_registerUser);
  }

  var registerUri = "api/Auth/RegisterAppUser";

  Future<void> _registerUser(RegisterUserEvent event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());
    try {
      final response = await ApiManager().post(
        (UrlApi.urlApiPor + registerUri),
        body: jsonEncode(event.registerRequest),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      handleApiResponse(
          response: response,
          onSuccess: () async {
            var data = RegisterResponse.fromJson(json.decode(response.body));
            emit(RegisterSuccess(registerResponse: data));
          },
          onFailure: (message) {
            SharedPrefs().isLoggedIn = false;
            print("Registration failed: $message");
            emit(RegisterFailure(error: message, RegisterResponse.fromJson(json.decode(response.body))));
          });
    } catch (e) {
      handleException(
          e: e,
          onFailure: (message) {
            SharedPrefs().isLoggedIn = false;
            emit(RegisterFailure(error: message, null));
          });
    }
  }
}
