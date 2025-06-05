import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'api_client.dart';

class AuthApi {
  final ApiClient _apiClient;

  AuthApi(this._apiClient);

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String secondName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required List<int> specializationIds,
  }) async {
    final response = await _apiClient.post('auth/register', {
      'first_name': firstName,
      'last_name': lastName,
      'second_name': secondName,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'specializationId': specializationIds,
    });
    
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    try {
      debugPrint('[Auth] Starting login for: $login');

      final response = await _apiClient.post(
        'auth/login',
        {
          'login': login.trim(),
          'password': password,
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('[Auth] Response data: ${data['data']}');

      if (data['data']['token'] == null) {
        throw Exception('Token not received in response');
      }

      _apiClient.setToken(data['data']['token'] as String);

      return data;
    } on FormatException {
      throw Exception('Invalid server response format');
    } catch (e, stackTrace) {
      debugPrint('[Auth] Login error: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _apiClient.get('auth/me');
    return jsonDecode(response.body);
  }

  Future<void> logout() async {
    await _apiClient.post('auth/logout', {});
    _apiClient.setToken(null);
  }
}