import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:nail_apps/models/client/client.dart';

import 'api_core.dart';

class ApiClient {
  final ApiCore _apiCore;

  ApiClient(this._apiCore);

  Future<List<Client>> getClients() async {
    try {
      final response =  await _apiCore.get('clients');
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Client.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load clients: $e');
    }
  }

  Future<Client> createClient(Client client) async {
    try {
      final response = await _apiCore.post('clients', client.toJson());
      final dynamic data = jsonDecode(response.body);
      return Client.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create client: $e');
    }
  }

  Future<Client> updateClient(Client client) async {
    try {
      final response = await _apiCore.put('clients/${client.id}', client.toJson());
      final dynamic data = jsonDecode(response.body);
      return Client.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update client: $e');
    }
  }

  Future<void> deleteClient(int clientId) async {
    try {
      await _apiCore.delete('clients/$clientId');
    } catch (e) {
      throw Exception('Failed to delete client: $e');
    }
  }
}