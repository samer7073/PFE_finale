// ignore_for_file: prefer_const_declarations

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

class ApiFamilyModuleData {
  static Future<List<dynamic>> getFamilyModuleData(String moduleId) async {
    final token = await SharedPrefernce.getToken("token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/get-family-module/$moduleId";
    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      log("helllo ****************************");
      log("Api function - ---------- :$responseData['data']");
      return responseData['data'];
    } else {
      throw Exception('Failed to load fields');
    }
  }

  static Future<List<dynamic>> getCountries() async {
    final token = await SharedPrefernce.getToken("token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/get-countries";
    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      log(responseData.toString());
      return responseData['data'];
    } else {
      throw Exception('Failed to load Countries');
    }
  }

  static Future<List<dynamic>> getCurrencies() async {
    final token = await SharedPrefernce.getToken("token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/get-currencies";
    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      log(responseData.toString());
      return responseData['data'];
    } else {
      throw Exception('Failed to load Currencies');
    }
  }
}
