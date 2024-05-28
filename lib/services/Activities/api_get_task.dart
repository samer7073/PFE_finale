import 'dart:convert';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getTaskDetails(String taskId) async {
  final url = Uri.parse('https://spherebackdev.cmk.biz:4543/api/mobile/tasks/$taskId/get');
   final token = await SharedPrefernce.getToken("token"); 

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load task details');
  }
}
