import 'dart:developer';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/shared/config.dart';

class TaskType {
  final int id;
  final String label;
  final String color;
  final String icon;

  TaskType({
    required this.id,
    required this.label,
    required this.color,
    required this.icon,
  });

  factory TaskType.fromJson(Map<String, dynamic> json) {
    return TaskType(
      id: json['id'],
      label: json['label'],
      color: json['color'] ?? '#FFFFFF', // Retourne couleur blanche si null
      icon: json['icons'],
    );
  }
}

Future<List<TaskType>> fetchTaskTypes() async {
  final token = await SharedPrefernce.getToken("token");
  final baseUrl = await Config.getApiUrl(
      'tasksConfig'); // Utilisation de l'URL définie dans Config.dart
  log(baseUrl);
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final response = await http.post(
    Uri.parse(baseUrl),
    headers: headers,
  );

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    List<TaskType> taskTypes = [];
    for (var type in jsonResponse['task_types']['tasks_type']) {
      taskTypes.add(TaskType.fromJson(type));
      log(TaskType.fromJson(type).label);
    }
    return taskTypes;
  } else {
    throw Exception('Failed to load task types Api: ${response.statusCode}');
  }
}
