// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/shared/config.dart';

Future<Map<String, dynamic>> getTaskDetails(String taskId) async {
  final baseUrl = await Config.getApiUrl('getTaskDetails');
  final url = Uri.parse(baseUrl +
      '/$taskId/get'); // Utilisation de l'URL définie dans Config.dart
  final token = await SharedPrefernce.getToken("token");

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load task details');
  }
}
