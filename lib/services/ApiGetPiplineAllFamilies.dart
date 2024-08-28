import 'dart:convert';
import 'dart:developer';

import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
// Import the configuration
import '../core/constants/shared/config.dart';
import '../models/pipelines/pipelineRespone.dart';

class GetPipelineApi {
  static Future<PipelineResponse> getPipelines(String idFamily) async {
    final token = await SharedPrefernce.getToken("token");

    final baseUrl = await Config.getApiUrl("pipelines");
    final url = "$baseUrl/$idFamily";
    log("***********************$url");

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
