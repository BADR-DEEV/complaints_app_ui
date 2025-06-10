import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class UrlApi {
  static String urlApiPor = 'http://192.168.1.12:5189/';
  static String staticUrl = 'http://localhost:5189/';
}

Future<void> handleApiResponse({
  required http.Response response,
  required Future<void> Function() onSuccess,
  required Function(String) onFailure,
}) async {
  if (response.statusCode == 200 || response.statusCode == 201) {
    await onSuccess();
  } else {
    String errorMessage;
    switch (response.statusCode) {
      case 400:
        errorMessage = '400 - Bad Request: ${response.body.toString()}';
        break;
      case 401:
        errorMessage = '401 - Unauthorized: ${response.body.toString()}';
        // onLogout();
        break;
      case 403:
        errorMessage = '403 - Forbidden: ${response.body.toString()}';
        break;
      case 404:
        errorMessage = '404 - Not Found: ${response.body.toString()}';
        break;
      case 409:
        errorMessage = '409 - Conflict: ${response.body.toString()}';
        break;
      case 413:
        errorMessage = '413 - Payload Too Large: The request entity is too large.';
        break;
      case 429:
        errorMessage = '429 - Too Many Requests: You have sent too many requests in a given amount of time.';
        break;
      case 500:
        errorMessage = '500 - Internal Server Error';
        log('Internal Server Error: ${response.body.toString()}');
        break;
      case 503:
        errorMessage = '503 - Service Unavailable: The server is currently unable to handle the request.';
        break;
      case 504:
        errorMessage = '504 - Gateway Timeout: The server took too long to respond.';
        break;
      default:
        errorMessage = 'Unexpected error (${response.statusCode}): ${response.body.toString()}';
    }
    log('Error ${response.statusCode}: ${errorMessage}');
    onFailure(errorMessage);
  }
}

void handleException({
  required Object e,
  required Function(String) onFailure,
}) {
  String errorMessage;
  if (e is SocketException) {
    errorMessage = 'No internet connection. Please check your network and try again. ${e.message}';
  } else if (e is TimeoutException) {
    errorMessage = 'Request timed out. The server might be taking too long to respond.';
  } else if (e is FormatException) {
    errorMessage = 'Response format error: Unable to process the response data.';
  } else if (e is HttpException) {
    errorMessage = 'An HTTP error occurred: ${e.message}';
  } else if (e is HandshakeException) {
    errorMessage = 'SSL handshake failed. There may be an issue with the server\'s certificate.';
  } else if (e is ClientException) {
    errorMessage = 'Client error occurred: ${e.message}';
  } else {
    errorMessage = 'An unexpected error occurred: ${e.toString()}';
  }
  log('Exception: $errorMessage');
  onFailure(errorMessage);
}

// void onLogout() {
//   SharedPrefs().isLoggedIn = false;
//   SharedPrefs().token = null;
//   SharedPrefs().customerId = null;
//   FirebaseApi().handleLogout();
//   clearAccountFromLocalStorage();
//   clearLoginFromLocalStorage();
//   clearRegisterFromLocalStorage();
//   ImageUploadService().deleteSavedProfileImage();
//   if (navigatorKey.currentState?.canPop() ?? false) {
//     navigatorKey.currentState?.popUntil((route) => route.isFirst);
//   }
//   // navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
//   final context = navigatorKey.currentContext;
//   if (context != null) {
//     Routes.navigateTo(context, '/login', clearStack: true, rootNavigator: true, maintainState: false);
//   }
// }