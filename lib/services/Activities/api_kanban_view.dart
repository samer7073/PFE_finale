import 'dart:convert';
import 'dart:developer';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/shared/config.dart';

Future<List<Task>> getTasksForKanban(String pipelineId, int stageId) async {
  final token = await SharedPrefernce.getToken("token");
  final baseUrl = await Config.getApiUrl(
    'kanbanTask',
  ); // Utilisation de l'URL définie dans Config.dart
  log("$baseUrl baseUrl");
  final url = Uri.parse('$baseUrl/tasks/get/kanban/$pipelineId');
  log(url.toString() + "999999999999999999999999999999999999999999");

  final headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    'Authorization': 'Bearer $token',
  };

  final response = await http.post(url, headers: headers);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final stages = data['stages'] as List;
    List<Task> tasks = [];

    for (var stage in stages) {
      if (stage['stage_id'] == stageId) {
        final stagePercent = stage['stage_percent'] ?? 0;
        final stageColor = stage['stage_color'] ?? '#000000';
        tasks = (stage['elements'] as List)
            .map<Task>((task) => Task.fromJson(task,
                stagePercent: stagePercent, stageColor: stageColor))
            .toList();
        break;
      }
    }

    return tasks;
  } else {
    final errorResponse = json.decode(response.body);
    throw Exception(
        'Failed to load tasks: ${errorResponse['message'] ?? 'Unknown error'}');
  }
}
