import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

import '../../core/constants/shared/config.dart';
// Importer Config.dart

Future<void> updateTaskPriority(String taskId, String newPriority) async {
  final token = await SharedPrefernce.getToken("token");
  final baseUrl = Config.getApiUrl(
      'updatePriority'); // Utilisation de l'URL définie dans Config.dart
  final url = '$baseUrl/tasks/$taskId/update/priority';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'priority': newPriority}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update task priority');
  }
}
