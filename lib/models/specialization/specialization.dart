import 'package:flutter/cupertino.dart';

class Specialization {
  final int id;
  final String name;

  Specialization({required this.id, required this.name});

  factory Specialization.fromJson(Map<String, dynamic> json) {
    try {
      return Specialization(
        id: json['id'] as int,
        name: json['name'] as String,
      );
    } catch (e) {
      throw Exception('Failed to parse Specialization: $e');
    }
  }
}