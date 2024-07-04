import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/constants/shared/config.dart';

Future<bool> deleteTasks(String taskId) async {
  try {
    final token = await SharedPrefernce.getToken("token");
    //const url = 'https://spherebackdev.cmk.biz:4543/api/mobile/tasks/delete';
    final basurl = await Config.getApiUrl("deleteTasks");
    final url = Uri.parse(basurl);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id': [taskId],
      }),
    );

    return response.statusCode == 200;
  } catch (e) {
    print('Error deleting task: $e');
    return false;
  }
}
