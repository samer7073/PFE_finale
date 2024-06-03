import 'dart:convert';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

class TaskLogService {
  final String fetchLogsUrl = "https://spherebackdev.cmk.biz:4543/api/mobile/tasks/log";
  final String markAsReadUrl = "https://spherebackdev.cmk.biz:4543/api/mobile/tasks/make-log-read";
  final String markAllAsReadUrl = "https://spherebackdev.cmk.biz:4543/api/mobile/tasks/make-all-logs-read";
  final String notificationNumberUrl = "https://spherebackdev.cmk.biz:4543/api/mobile/tasks/notification-number";
  final String dashboardUrl = "https://spherebackdev.cmk.biz:4543/api/mobile/tasks/dashboard";

  Future<Map<String, dynamic>> fetchTaskLogs() async {
    final token = await SharedPrefernce.getToken("token");
    final response = await http.get(
      Uri.parse(fetchLogsUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load task logs');
    }
  }

  Future<Map<String, dynamic>> markLogAsRead(String logId, int taskId, String action) async {
    final token = await SharedPrefernce.getToken("token");
    final response = await http.post(
      Uri.parse(markAsReadUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'log_id': logId,
        'task_id': taskId,
        'action': action,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to mark log as read');
    }
  }

  Future<Map<String, dynamic>> markAllLogsAsRead() async {
    final token = await SharedPrefernce.getToken("token");
    final response = await http.post(
      Uri.parse(markAllAsReadUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to mark all logs as read');
    }
  }

  Future<Map<String, dynamic>> getNotificationNumber() async {
    final token = await SharedPrefernce.getToken("token");
    final response = await http.get(
      Uri.parse(notificationNumberUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get notification number');
    }
  }

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
