// ignore_for_file: prefer_const_declarations

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_application_stage_project/models/jwt/ApiResponseJwt.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

class ApiGetJwt {
  static Future<ApiResponseJwt> getJwt() async {
    log("JWT api");
    final token = await SharedPrefernce.getToken("token");

    final url = "https://spherechatbackdev.cmk.biz:4543/index.php/api/user";
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

      // Accéder à la clé "data" et créer un objet Profile

      return ApiResponseJwt.fromJson(responseData);
    } else {
      throw Exception('Failed to load tickets');
    }
  }
}
