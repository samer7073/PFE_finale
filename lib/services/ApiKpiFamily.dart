import 'dart:convert';
import 'dart:developer';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

import '../models/KpiFamily/KpiResponseModel.dart';

class ApiKpiFamily {
  static Future<KpiResponseModel> getKpiFamily(String idFamily) async {
    log("Fetching data from API");
    final token = await SharedPrefernce.getToken("token");
    log("Token: $token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/kpi-family/$idFamily";

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
      return KpiResponseModel.fromJson(responseData);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
