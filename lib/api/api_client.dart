import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:nail_apps/models/client/client.dart';

class ApiClient {
  static const String baseUrl = 'https://ac7bc8667b91aa6c8af14f4805933737.serveo.net/api/v1';
  String? _token;

  ApiClient();

  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(url, headers: _buildHeaders(headers));
    return _handleResponse(response);
  }

  Future<http.Response> post(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    final requestHeaders = _buildHeaders(headers);

    debugPrint('[API Request]');
    debugPrint('URL: $url');
    debugPrint('Method: POST');
    debugPrint('Headers: $requestHeaders');
    debugPrint('Body: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(body),
    );

    debugPrint('[API Response]');
    debugPrint('Response: $response');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Headers: ${response.headers}');
    debugPrint('Body: ${response.body}');

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

  Future<List<Client>> getClients() async {
    try {
      final response = await get('clients');
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Client.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load clients: $e');
    }
  }

  Future<Client> createClient(Client client) async {
    try {
      final response = await post('clients', client.toJson());
      final dynamic data = jsonDecode(response.body);
      return Client.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create client: $e');
    }
  }

  Future<Client> updateClient(Client client) async {
    try {
      final response = await put('clients/${client.id}', client.toJson());
      final dynamic data = jsonDecode(response.body);
      return Client.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update client: $e');
    }
  }

  Future<void> deleteClient(int clientId) async {
    try {
      await delete('clients/$clientId');
    } catch (e) {
      throw Exception('Failed to delete client: $e');
    }
  }
}