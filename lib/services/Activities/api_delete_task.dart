import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> deleteTasks(List<String> taskIds) async {
  final token = await SharedPrefernce.getToken("token");
  const url = 'https://spherebackdev.cmk.biz:4543/api/mobile/tasks/delete';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({"id": taskIds}),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
