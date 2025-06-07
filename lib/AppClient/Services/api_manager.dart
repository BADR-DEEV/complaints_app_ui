import 'dart:developer';
import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:http/http.dart' as http;

class ApiManager {
  // Helper to get auth headers with bearer token
  Map<String, String> _getAuthHeaders([Map<String, String>? extraHeaders]) {
    final token = SharedPrefs().token ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      ...?extraHeaders,
    };
  }

  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse(url),
      headers: _getAuthHeaders(headers),
    );
    return response;
  }

  Future<http.Response> post(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final response = await http.post(
      Uri.parse(url),
      headers: _getAuthHeaders(headers),
      body: body,
    );
    return response;
  }

  Future<http.Response> put(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final response = await http.put(
      Uri.parse(url),
      headers: _getAuthHeaders(headers),
      body: body,
    );
    return response;
  }

  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await http.delete(
      Uri.parse(url),
      headers: _getAuthHeaders(headers),
    );
    return response;
  }
}
