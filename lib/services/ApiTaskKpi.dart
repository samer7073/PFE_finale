import 'dart:convert';
import 'dart:developer';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

import '../models/TaskpiModel.dart';

class ApiTaskKpi {
  static Future<TaskKpiModel> getApiResponse() async {
    log("Fetching data from API");
    final token = await SharedPrefernce.getToken("token");
    log("Token: $token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/tasks/kpi";

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
      return TaskKpiModel.fromJson(responseData);
    } else {
      log(response.body);
      throw Exception('Failed to load data');
    }
  }
}
