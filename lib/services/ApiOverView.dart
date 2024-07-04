import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import '../core/constants/shared/config.dart';
import '../models/ouverviewModel.dart';
// Importez la configuration

class ApiOverVeiw {
  static Future<OverviewModelRespone> getOverview(
    String idElement,
    String idFamily,
  ) async {
    log("ticket api");
    final token = await SharedPrefernce.getToken("token");
    log("$token");

    final baseUrl = await Config.getApiUrl("overview");
    final url = "$baseUrl/$idFamily/$idElement";

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
      return OverviewModelRespone.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Details');
    }
  }
}
