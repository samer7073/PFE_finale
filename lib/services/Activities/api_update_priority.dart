import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

Future<void> updateTaskPriority(String taskId, String newPriority) async {
  final token = await SharedPrefernce.getToken("token");

  final response = await http.post(
    Uri.parse(
        'https://spherebackdev.cmk.biz:4543/api/mobile/tasks/$taskId/update/priority'),
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
