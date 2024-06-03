import 'dart:convert';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

class TaskLogService {

final String dashboardUrl = "https://spherebackdev.cmk.biz:4543/api/mobile/tasks/dashboard";

Future<Map<String, dynamic>> getDashboardData(String start, String end) async {
    final token = await SharedPrefernce.getToken("token");
    final response = await http.post(
      Uri.parse(dashboardUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'start': start,
        'end': end,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get dashboard data');
    }
  }
}