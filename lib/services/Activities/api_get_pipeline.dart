// lib/services/api_service.dart

import 'dart:developer';

import 'package:flutter_application_stage_project/models/Activity_models/pipeline.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/constants/shared/config.dart';

Future<List<Pipeline>> getPipelines(String moduleSystem) async {
  final token = await SharedPrefernce.getToken("token");
  final apiUrl = await Config.getApiUrl(
      "getPipelines"); // Utilisation de l'URL de production
  // ou Config.getApiUrl("getPipelines", false) pour l'URL de développement

  final url = '$apiUrl/$moduleSystem';
  log(url + "88888888888888888888888888888");

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
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse
          .map((pipeline) => Pipeline.fromJson(pipeline))
          .toList();
    } else {
      throw Exception('Failed to load pipelines');
    }
  } catch (e) {
    throw Exception('Error occurred while loading pipelines: $e');
  }
}
