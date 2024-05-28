import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


Future<void> addChatRoomToTask(String source, String taskId) async {
  final token = await SharedPrefernce.getToken("token");
  final response = await http.get(
    Uri.parse('https://spherebackdev.cmk.biz:4543/api/mobile/tasks/$taskId/update/room'),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    print('Chat room details: ${response.body}');
  } else {
    throw Exception('Failed to get chat room details');
  }
}

Future<void> updateChatRoomForTask(String taskId, int roomId) async {
  final token = await SharedPrefernce.getToken("token");
  final response = await http.post(
    Uri.parse('https://spherebackdev.cmk.biz:4543/api/mobile/update-task/room/$taskId'),
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
    print('Chat room updated successfully');
  } else {
    throw Exception('Failed to update chat room');
  }
}
