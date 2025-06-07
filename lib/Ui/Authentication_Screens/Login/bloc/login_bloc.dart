import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:complaintsapp/AppClient/Models/LoginDtos/login_req.dart';
import 'package:complaintsapp/AppClient/Models/LoginDtos/login_res.dart';
import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:complaintsapp/AppClient/Services/_urlApi.dart';
import 'package:complaintsapp/AppClient/Services/api_manager.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginUserEvent>(_loginUser);
  }

  var loginUri = "api/Auth/LoginAppUser";
  var registerUri = "api/Auth/RegisterAppUser";

  Future<void> _loginUser(LoginUserEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final response = await ApiManager().post(
        (UrlApi.urlApiPor + loginUri),
        body: jsonEncode(event.loginRequest),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      handleApiResponse(
          response: response,
          onSuccess: () async {
            var data = LoginResponse.fromJson(json.decode(response.body));
            emit(LoginSuccess(loginResponse: data));
            SharedPrefs().isLoggedIn = true;
            SharedPrefs().userEmail = event.loginRequest.email;
            SharedPrefs().token = data.data?.accessToken;
            SharedPrefs().userName = data.data?.displayName ?? '';
          },
          onFailure: (message) {
            print("Login failed: $message");
            emit(LoginFailure(error: message, LoginResponse.fromJson(json.decode(response.body))));
          });
    } catch (e) {
      handleException(
          e: e,
          onFailure: (message) {
            emit(LoginFailure(error: message, null));
          });
    }
  }
}
