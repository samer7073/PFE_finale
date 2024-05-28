// ignore_for_file: prefer_const_declarations

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:flutter_application_stage_project/models/detailModel.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

class ApiDetailElment {
  static Future<DetailResponse> getDetail(String idElment) async {
    log("ticket api");
    final token = await SharedPrefernce.getToken("token");
    log("$token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/get-element-by-id/$idElment";
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
      return DetailResponse.fromJson(responseData);
    } else {
      throw Exception('Failed to load Details');
    }
  }
}
