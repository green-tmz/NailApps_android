import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ApiCore {
  static const String baseUrl = 'http://127.0.0.1:85/api/v1';
  // static const String baseUrl = 'https://2300aaf70d6540.lhr.life/api/v1';
  String? _token;

  ApiCore();

  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(url, headers: _buildHeaders(headers));
    return _handleResponse(response);
  }

  Future<http.Response> post(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    final requestHeaders = _buildHeaders(headers);

    final response = await http.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<http.Response> put(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.put(
      url,
      headers: _buildHeaders(headers),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.delete(url, headers: _buildHeaders(headers));
    return _handleResponse(response);
  }

  Map<String, String> _buildHeaders(Map<String, String>? additionalHeaders) {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
    return response;
  }

  void setToken(String? token) {
    _token = token;
  }
}