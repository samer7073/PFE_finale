import 'dart:convert';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://spherebackdev.cmk.biz:4543/api/mobile';

Future<List<Task>> filterTasks({
  String? priority,
  String? label,
  String? tasksTypeId,
  DateTime? startDate,
  DateTime? endDate,
  String? familyLabel,
}) async {
  final token = await SharedPrefernce.getToken("token");

  // Préparer les paramètres de requête
  final Map<String, String> queryParams = {};
  if (priority != null) queryParams['priority'] = priority;
  if (label != null) queryParams['label'] = label;
  if (tasksTypeId != null) queryParams['tasks_type_id'] = tasksTypeId;
  if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
  if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
  if (familyLabel != null) queryParams['family_label'] = familyLabel;

  final url = Uri.parse('$baseUrl/filter-tasks').replace(queryParameters: queryParams);
  final headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    'Authorization': 'Bearer $token',
  };

  final response = await http.get(
    url,
    headers: headers,
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List<Task> tasks =
        (data['data'] as List).map((item) => Task.fromJson(item)).toList();
    return tasks;
  } else {
    final errorResponse = json.decode(response.body);
    throw Exception(
        'Failed to filter tasks: ${errorResponse['message'] ?? 'Unknown error'}');
  }
}
