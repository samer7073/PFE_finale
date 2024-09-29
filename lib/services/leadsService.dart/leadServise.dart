import 'dart:convert';
import 'dart:developer';

import 'package:flutter_application_stage_project/models/leads_models/lead.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/shared/config.dart';
import '../sharedPreference.dart';
// Importer le fichier de configuration

class ServiceLeads {
  static Future<List<Lead>> getAllLeads(
      {int page = 1, String search = ''}) async {
    log("Fetching Leads from API");
    final token = await SharedPrefernce.getToken("token");
    log("Token: $token");

    // Utilisation de Config pour obtenir l'URL
    final baseUrl = await Config.getApiUrl('leads');
    final url = "$baseUrl?limit=10&page=$page&search=$search";
    log(url);
    log("search" + search);

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      log("Response: ${response.body}");
      final Map<String, dynamic> responseData = json.decode(response.body);
      return parseDeals(responseData);
    } else {
      log("Failed to load Leads: ${response.statusCode}");
      throw Exception('Failed to load Leads');
    }
  }

  static List<Lead> parseDeals(Map<String, dynamic> responseBody) {
    final parsed = responseBody['data'] as List;
    return parsed.map<Lead>((json) => Lead.fromJson(json)).toList();
  }

 
}
