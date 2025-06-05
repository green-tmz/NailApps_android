import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'api_core.dart';

class AuthApi {
  final ApiCore _apiCore;
  String? _userName;

  AuthApi(this._apiCore);

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
    final response = await _apiCore.post('auth/register', {
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

      final response = await _apiCore.post(
        'auth/login',
        {
          'login': login.trim(),
          'password': password,
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['data']['token'] == null) {
        throw Exception('Token not received in response');
      }

      _apiCore.setToken(data['data']['token'] as String);

      return data;
    } on FormatException {
      throw Exception('Invalid server response format');
    } catch (e, stackTrace) {
      debugPrint('[Auth] Login error: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _apiCore.get('auth/me');
    final data = jsonDecode(response.body);
    _userName = data['data']['first_name'] + ' ' + data['data']['last_name'];
    return jsonDecode(response.body);
  }

  Future<void> logout() async {
    await _apiCore.post('auth/logout', {});
    _apiCore.setToken(null);
  }
}