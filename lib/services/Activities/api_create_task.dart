import 'dart:convert';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

Future<Task> createTask(Map<String, dynamic> taskData) async {
  final token = await SharedPrefernce.getToken("token");
  final url = Uri.parse('https://spherebackdev.cmk.biz:4543/api/mobile/tasks/create');

  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final body = json.encode(taskData);

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Task.fromJson(jsonResponse); // Assuming Task has a fromJson constructor
    } else {
      throw Exception('Failed to create task: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error occurred while creating task: $e');
  }
}
