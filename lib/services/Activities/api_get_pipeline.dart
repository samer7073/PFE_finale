// api_service.dart
import 'dart:convert';
import 'package:flutter_application_stage_project/models/Activity_models/pipeline.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

 const String baseUrl = 'https://spherebackdev.cmk.biz:4543/api/mobile';

  Future<List<Pipeline>> getPipelines(String moduleSystem) async {
    final token = await SharedPrefernce.getToken("token"); 
    final response = await http.get(
      Uri.parse('$baseUrl/pipelines-by-module-system/$moduleSystem'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((pipeline) => Pipeline.fromJson(pipeline)).toList();
    } else {
      throw Exception('Failed to load pipelines');
    }
  }

 