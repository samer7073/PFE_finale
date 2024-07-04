import 'dart:convert';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/shared/config.dart';

Future<Map<String, dynamic>> fetchTasks(int page) async {
  final token = await SharedPrefernce.getToken("token");
  final baseUrl = await Config.getApiUrl(
    'fetchTasks',
  );
  final url = Uri.parse(baseUrl +
      '/get/table?page=$page'); // Utilisation de l'URL définie dans Config.dart
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode({}),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final List<Task> tasks = (jsonResponse['data'] as List)
        .map((task) => Task.fromJson(task))
        .toList();
    return {
      'tasks': tasks,
      'meta': jsonResponse['meta'],
    };
  } else {
    throw Exception('Failed to load tasks');
  }
}
