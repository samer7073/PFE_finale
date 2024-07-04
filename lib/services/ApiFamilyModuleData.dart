// ignore_for_file: prefer_const_declarations

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import '../core/constants/shared/config.dart'; // Importer le fichier de configuration

class ApiFamilyModuleData {
  static Future<List<dynamic>> getFamilyModuleData(String moduleId) async {
    final token = await SharedPrefernce.getToken("token");
    final url = await Config.getApiUrl(
          "familyModuleData",
        ) +
        "/$moduleId"; // Utilisation de Config pour obtenir l'URL
    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      log("Family Module Data Response: $responseData");
      return responseData['data'];
    } else {
      throw Exception('Failed to load family module data');
    }
  }

  static Future<List<dynamic>> getCountries() async {
    final token = await SharedPrefernce.getToken("token");
    final url = await Config.getApiUrl(
      "countries",
    ); // Utilisation de Config pour obtenir l'URL
    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      log("Countries Response: $responseData");
      return responseData['data'];
    } else {
      throw Exception('Failed to load countries');
    }
  }

  static Future<List<dynamic>> getCurrencies() async {
    final token = await SharedPrefernce.getToken("token");
    final url = await Config.getApiUrl(
        "currencies"); // Utilisation de Config pour obtenir l'URL
    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      log("Currencies Response: $responseData");
      return responseData['data'];
    } else {
      throw Exception('Failed to load currencies');
    }
  }
}
