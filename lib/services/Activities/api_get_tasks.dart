import 'dart:convert';
import 'dart:developer';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

import 'package:http/http.dart' as http;
import '../../core/constants/shared/config.dart';

class TaskService {
  static Future<Map<String, dynamic>> fetchTasks(int page) async {
    try {
      final token = await SharedPrefernce.getToken("token");
      final baseUrl = await Config.getApiUrl('fetchTasks');
      final url = Uri.parse('$baseUrl/get/table?page=$page');
      log('Request URL: $url');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        log('Response JSON: $jsonResponse');

        if (jsonResponse.containsKey('data') &&
            jsonResponse.containsKey('meta')) {
          final List<Task> tasks = (jsonResponse['data'] as List)
              .map((task) => Task.fromJson(task))
              .toList();

          return {
            'tasks': tasks,
            'meta': jsonResponse['meta'],
          };
        } else {
          log('Invalid response format: ${response.body}');
          throw Exception('Invalid response format');
        }
      } else {
        log('Failed to load tasks: ${response.body}');
        throw Exception('Failed to load tasks: ${response.body}');
      }
    } catch (e) {
      log('Error fetching tasks: $e');
      throw Exception('Error fetching tasks: $e');
    }
  }
}
