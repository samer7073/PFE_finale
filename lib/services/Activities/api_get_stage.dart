// lib/services/api_service.dart

import 'dart:developer';

import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/constants/shared/config.dart';

Future<List<dynamic>> fetchStages() async {
  final token = await SharedPrefernce.getToken("token");
  final apiUrl = await Config.getApiUrl(
      "fetchStages"); // Utilisation de l'URL de production
  // ou Config.getApiUrl("fetchStages", false) pour l'URL de développement

  log("8888888888888888888888 $apiUrl");

  final url = '$apiUrl';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception(
          'Failed to load stages: Status code ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error occurred while loading stages: $e');
  }
}

