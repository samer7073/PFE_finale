import 'dart:convert';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://spherebackdev.cmk.biz:4543/api/mobile';

Future<List<Task>> getTasksForKanban(String pipelineId, int stageId) async {
  final token = await SharedPrefernce.getToken("token");
  
  final url = Uri.parse('$baseUrl/tasks/get/kanban/$pipelineId');
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
        tasks = (stage['elements'] as List).map<Task>((task) => Task.fromJson(task)).toList();
        break;
      }
    }

    return tasks;
  } else {
    final errorResponse = json.decode(response.body);
    throw Exception('Failed to load tasks: ${errorResponse['message'] ?? 'Unknown error'}');
  }
}
