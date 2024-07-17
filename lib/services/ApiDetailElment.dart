// ignore_for_file: prefer_const_declarations, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_application_stage_project/models/detailModel.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

import '../core/constants/shared/config.dart';
// Importer le fichier de configuration

class ApiDetailElment {
  static Future<DetailResponse> getDetail(String idElment) async {
    log("ticket api");
    final token = await SharedPrefernce.getToken("token");
    log("$token");
    final baseUrl = await Config.getApiUrl('getDetail');
    
    final url =
        baseUrl + "/$idElment"; // Utilisation de Config pour obtenir l'URL
    log(url);
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
      log(response.statusCode.toString());
      throw Exception('Failed to load Details');
    }
  }
}
