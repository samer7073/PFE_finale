import 'dart:convert';
import 'dart:developer';

import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/shared/config.dart';

Future<Task> createTask(Map<String, dynamic> taskData) async {
  // Fetch token from shared preferences
  final token = await SharedPrefernce.getToken("token");

  // Get the base URL for the API endpoint
  final baseUrl = await Config.getApiUrl("createTask");
  final url = Uri.parse(baseUrl);

  // Define headers for the HTTP request
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Convert the task data to JSON
  final body = json.encode(taskData);
  log("body111111111111111111111111: $body");

  try {
    // Send the HTTP POST request
    final response = await http.post(url, headers: headers, body: body);

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final jsonResponse = json.decode(response.body);

      // Create and return a Task object from the JSON response
      return Task.fromJson(jsonResponse);
    } else {
      // Throw an exception if the request failed
      throw Exception('Failed to create task: ${response.body}');
    }
  } catch (e) {
    // Handle any errors that occur during the request
    throw Exception('Error occurred while creating task: $e');
  }
}
