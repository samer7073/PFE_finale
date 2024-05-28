import 'dart:convert';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getTasks({
  String? search,
  int? pipelineId,
  List<int>? stagesIds,
  List<String>? priorities,
  bool? export,
  List<int>? roles,
}) async {
  final url = Uri.parse('https://spherebackdev.cmk.biz:4543/api/mobile/tasks/get/table');
  final token = await SharedPrefernce.getToken("token"); 
  final body = json.encode({
    'search': search,
    'pipeline_id': pipelineId,
    'stages_ids': stagesIds?.join(','),
    'priorities': priorities?.join(','),
    'export': export,
    'roles': roles?.join(','),
  });

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: body,
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load tasks');
  }
}