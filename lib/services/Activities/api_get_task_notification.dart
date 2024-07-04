// lib/services/api_service.dart

import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/constants/shared/config.dart';

class TaskLogService {
  Future<Map<String, dynamic>> fetchTaskLogs() async {
    final token = await SharedPrefernce.getToken("token");
    final apiUrl = await Config.getApiUrl(
        "fetchTaskLogs"); // Utilisation de l'URL de production
    // ou Config.getApiUrl("fetchTaskLogs", false) pour l'URL de développement

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
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
    } catch (e) {
      throw Exception('Error occurred while fetching task logs: $e');
    }
  }

  Future<Map<String, dynamic>> markLogAsRead(
      String logId, int taskId, String action) async {
    final token = await SharedPrefernce.getToken("token");
    final apiUrl = await Config.getApiUrl(
      "markAsRead",
    ); // Utilisation de l'URL de production
    // ou Config.getApiUrl("markAsRead", false) pour l'URL de développement

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
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
    } catch (e) {
      throw Exception('Error occurred while marking log as read: $e');
    }
  }

  Future<Map<String, dynamic>> markAllLogsAsRead() async {
    final token = await SharedPrefernce.getToken("token");
    final apiUrl = await Config.getApiUrl(
      "markAllAsRead",
    ); // Utilisation de l'URL de production
    // ou Config.getApiUrl("markAllAsRead", false) pour l'URL de développement

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
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
    } catch (e) {
      throw Exception('Error occurred while marking all logs as read: $e');
    }
  }

  Future<Map<String, dynamic>> getNotificationNumber() async {
    final token = await SharedPrefernce.getToken("token");
    final apiUrl = await Config.getApiUrl(
        "notificationNumber"); // Utilisation de l'URL de production
    // ou Config.getApiUrl("notificationNumber", false) pour l'URL de développement

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
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
    } catch (e) {
      throw Exception('Error occurred while getting notification number: $e');
    }
  }

  Future<Map<String, dynamic>> getDashboardData(
      String start, String end) async {
    final token = await SharedPrefernce.getToken("token");
    final apiUrl = await Config.getApiUrl(
        "dashboardData"); // Utilisation de l'URL de production
    // ou Config.getApiUrl("dashboardData", false) pour l'URL de développement

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
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
    } catch (e) {
      throw Exception('Error occurred while getting dashboard data: $e');
    }
  }
}
