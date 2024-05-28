import 'dart:convert';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class TaskApiService {
  static const String baseUrl = 'https://spherebackdev.cmk.biz:4543/api/mobile';

  static Future<List<dynamic>> fetchTaskLogs() async {
    final token = await SharedPrefernce.getToken("token");
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await http.get(
      Uri.parse('$baseUrl/tasks/log?date=$todayDate'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load task logs');
    }
  }

  static Future<int> fetchNotificationCount() async {
    final token = await SharedPrefernce.getToken("token");
    final response = await http.get(
      Uri.parse('$baseUrl/tasks/notification-number'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final taskCount = jsonResponse['task_count'];
      final visioCount = jsonResponse['visio_count'];
      if (taskCount != null && visioCount != null) {
        return taskCount + visioCount;
      } else {
        throw Exception('Notification counts are null');
      }
    } else {
      throw Exception('Failed to load notification count');
    }
  }

  static Future<void> updateTaskLogRead(String logId, String taskId) async {
    final token = await SharedPrefernce.getToken("token");
    final response = await http.post(
      Uri.parse('$baseUrl/tasks/make-log-read'),
      body: jsonEncode({
        'log_id': logId,
        'task_id': taskId,
        'action': 'read',
      }),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task log');
    }
  }

  static Future<void> updateAllTaskLogsRead() async {
    final token = await SharedPrefernce.getToken("token");
    final response = await http.post(
      Uri.parse('$baseUrl/tasks/make-all-logs-read'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update all task logs');
    }
  }
}
