import 'dart:developer';

import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/constants/shared/config.dart';

Future<void> addChatRoomToTask(String taskId) async {
  final token = await SharedPrefernce.getToken("token");
  final baseUrl = await Config.getApiUrl("addChatRoomToTask");
  final url = Uri.parse(baseUrl.replaceAll('{taskId}', taskId));

  try {
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      log('Chat room details: ${response.body}');
    } else {
      throw Exception('Failed to get chat room details');
    }
  } catch (e) {
    log('Error in addChatRoomToTask: $e');
    throw Exception('Failed to get chat room details');
  }
}

Future<void> updateChatRoomForTask(String taskId, int roomId) async {
  final token = await SharedPrefernce.getToken("token");
  final baseUrl = await Config.getApiUrl("updateChatRoomForTask");
  final url = Uri.parse(baseUrl.replaceAll('{taskId}', taskId));

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'room_id': roomId,
      }),
    );

    if (response.statusCode == 200) {
      log('Chat room updated successfully');
    } else {
      throw Exception('Failed to update chat room');
    }
  } catch (e) {
    log('Error in updateChatRoomForTask: $e');
    throw Exception('Failed to update chat room');
  }
}
