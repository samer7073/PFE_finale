import 'dart:convert';
import 'dart:developer';
import 'package:flutter_application_stage_project/models/contactModel/ContactModelDetails/ApiResponseContactDeatils.dart';
import 'package:flutter_application_stage_project/models/contactModel/data.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/shared/config.dart';
import '../sharedPreference.dart';
// Importer le fichier de configuration

class ApiContact {
  static Future<List<Data>> getAllContact(
      {int page = 1, String search = ''}) async {
    log("Fetching contact from API");
    final token = await SharedPrefernce.getToken("token");
    log("Token: $token");

    // Utilisation de Config pour obtenir l'URL
    final baseUrl = await Config.getApiUrl('getDirectory');
    final url = "$baseUrl?page=$page&search=$search";
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
      log("Failed to load Contact: ${response.statusCode}");
      throw Exception('Failed to load Contact');
    }
  }

  static List<Data> parseDeals(Map<String, dynamic> responseBody) {
    final parsed = responseBody['data'] as List;
    return parsed.map<Data>((json) => Data.fromJson(json)).toList();
  }

  static Future<ApiResponseContactDetails> getAllContactsDetails(
      String id_Contact) async {
    log("Contact Deatails ap--------i");
    final token = await SharedPrefernce.getToken("token");
    log("$token");

    // Utilisation de Config pour obtenir l'URL
    final baseUrl = await Config.getApiUrl('getElementDetails');
    final url = "$baseUrl/$id_Contact";

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
      return ApiResponseContactDetails.fromJson(responseData);
    } else {
      throw Exception('Failed to load tickets');
    }
  }
}
