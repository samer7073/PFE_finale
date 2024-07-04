import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../../core/constants/shared/config.dart';
import '../../models/Deal/DealModel.dart';
import '../sharedPreference.dart';
// Importer le fichier de configuration

class ApiDeal {
  static Future<List<Deal>> getAllDeals(String idFamily, {int page = 1}) async {
    log("Fetching deals from API");
    final token = await SharedPrefernce.getToken("token");
    log("Token: $token");

    // Utilisation de Config pour obtenir l'URL
    final baseUrl = await Config.getApiUrl('getElementsByFamily');
    final url = "$baseUrl/$idFamily?page=$page&limit=10";

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
      log("Failed to load deals: ${response.statusCode}");
      throw Exception('Failed to load deals');
    }
  }

  static List<Deal> parseDeals(Map<String, dynamic> responseBody) {
    final parsed = responseBody['data'] as List;
    return parsed.map<Deal>((json) => Deal.fromJson(json)).toList();
  }
}
