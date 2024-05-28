import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



  Future<bool> updateTask(
    String taskId,
    Map<String, dynamic> taskData,
  ) async {
    final token = await SharedPrefernce.getToken("token"); 
    final url = 'https://spherebackdev.cmk.biz:4543/api/mobile/tasks/$taskId/update';
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(taskData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update task: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

