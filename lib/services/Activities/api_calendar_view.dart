import 'dart:convert';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
// Importer le fichier de configuration
import 'package:http/http.dart' as http;

import '../../core/constants/shared/config.dart';

Future<List<Task>> fetchTasks(String start, String end) async {
  final baseUrl = await Config.getApiUrl(
    'getTasksCalendar',
  ); // Utiliser Config pour obtenir l'URL
  final url = Uri.parse(baseUrl);

  final token = await SharedPrefernce.getToken("token");

  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final body = json.encode({
    'start': start,
    'end': end,
  });

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final taskData = data['data'] as List;
    final tasks = taskData.map((item) => Task.fromJson(item)).toList();
    return tasks;
  } else {
    final errorResponse = json.decode(response.body);
    throw Exception(
        'Failed to load tasks: ${errorResponse['message'] ?? 'Unknown error'}');
  }
}
