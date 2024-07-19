import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../core/constants/shared/config.dart';
import '../../models/ticket/ticketData.dart';
import '../sharedPreference.dart';

class ApiTicketList {
  Future<List<TicketData>> getTicketList({
    String? query,
    String? idFamily,
    int page = 1,
    int pageSize = 10,
  }) async {
    List<TicketData> results = [];
    log("ticket api");
    final token = await SharedPrefernce.getToken("token");

    // Utilisation de Config pour obtenir l'URL
    final baseUrl = await Config.getApiUrl('getElementsByFamily');
    final url = '$baseUrl/$idFamily?page=$page&limit=$pageSize&search=$query';
    log("4444444444444444444444444444" + url);

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    try {
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'] as List;
        results = data.map((e) => TicketData.fromJson(e)).toList();
        log(results.toString());
      } else {
        log("fetch error: ${response.statusCode}");
      }
    } on Exception catch (e) {
      log('error: $e');
    }
    return results;
  }
}
