import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_stage_project/models/ticket/ticket.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import '../../core/constants/shared/config.dart';

class GetTicketApi {
  static Future<Ticket> getAllTickets(String idFamily, {int page = 1}) async {
    log("Fetching tickets from API");
    final token = await SharedPrefernce.getToken("token");
    log("Token: $token");

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
      return Ticket.fromJson(responseData);
    } else {
      log("Failed to load tickets: ${response.statusCode}");
      throw Exception('Failed to load tickets');
    }
  }
}
