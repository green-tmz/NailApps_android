import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:nail_apps/models/specialization/specialization.dart';
import 'api_core.dart';

class SpecializationApi {
  final ApiCore _apiCore;

  SpecializationApi(this._apiCore);

  Future<List<Specialization>> getSpecializations() async {
    try {
      final response = await _apiCore.get('specializations');
      final data = jsonDecode(response.body);

      if (data is List) {
        return data.map((json) => Specialization.fromJson(json)).toList();
      } else if (data['data'] != null) {
        return (data['data'] as List).map((json) => Specialization.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      debugPrint("Error in getSpecializations: $e");
      throw Exception('Failed to load specializations: $e');
    }
  }

  Future<Specialization> getSpecialization(int id) async {
    try {
      final response = await _apiCore.get('specializations/$id');
      final dynamic data = jsonDecode(response.body);
      return Specialization.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load specialization: $e');
    }
  }

  Future<Specialization> createSpecialization(String name) async {
    try {
      final response = await _apiCore.post(
        'specializations',
        {'name': name},
      );
      final dynamic data = jsonDecode(response.body);
      return Specialization.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create specialization: $e');
    }
  }

  Future<Specialization> updateSpecialization(int id, String name) async {
    try {
      final response = await _apiCore.put(
        'specializations/$id',
        {'name': name},
      );
      final dynamic data = jsonDecode(response.body);
      return Specialization.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update specialization: $e');
    }
  }

  Future<void> deleteSpecialization(int id) async {
    try {
      await _apiCore.delete('specializations/$id');
    } catch (e) {
      throw Exception('Failed to delete specialization: $e');
    }
  }
}