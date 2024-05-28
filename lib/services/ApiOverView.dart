import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

import '../models/ouverviewModel.dart';

class ApiOverVeiw {
  static Future<OverviewModelRespone> getOverview(
      String idElment, String idFamily) async {
    log("ticket api");
    final token = await SharedPrefernce.getToken("token");
    log("$token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/log-family-elements/$idFamily/$idElment";
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
