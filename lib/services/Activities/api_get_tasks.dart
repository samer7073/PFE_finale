import 'dart:convert';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchTasks(int page) async {
  final token = await SharedPrefernce.getToken("token");
  final response = await http.post(
    Uri.parse('https://spherebackdev.cmk.biz:4543/api/mobile/tasks/get/table?page=$page'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
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
