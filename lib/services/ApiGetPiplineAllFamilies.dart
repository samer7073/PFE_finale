import 'dart:developer';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/pipelines/pipelineRespone.dart';

class GetPipelineApi {
  static Future<PipelineResponse> getPipelines(String idFamily) async {
    final token = await SharedPrefernce.getToken("token");

    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/pipelines-by-family/$idFamily";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      log(response.body);
      final Map<String, dynamic> responseData = json.decode(response.body);
      return PipelineResponse.fromJson(responseData);
    } else {
      throw Exception('Failed to load pipelines');
    }
  }
}
