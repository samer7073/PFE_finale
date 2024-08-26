import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/constants/shared/config.dart';

/*
Future<bool> updateTaskStage(String taskId, int newStageId) async {
  const url =
      'https://spherebackdev.cmk.biz:4543/api/mobile/tasks/update/stage'; // Replace with your API URL
  final token = await SharedPrefernce.getToken("token");
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final body = jsonEncode({
    'task_id': taskId,
    'new_stage_id': newStageId,
  });

  final response =
      await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
*/
Future<bool> updateTaskStage(String taskId, int newStageId) async {
  final baseUrl = await Config.getApiUrl('updateStageFamilyTask');
  final url =
      Uri.parse(baseUrl); // Utilisation de l'URL définie dans Config.dart
  final token = await SharedPrefernce.getToken("token");
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final body = jsonEncode({
    'task_id': taskId,
    'new_stage_id': newStageId,
  });

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
