import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_stage_project/models/ticket/ticket.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

import '../../core/constants/shared/config.dart'; // Importer le fichier de configuration

class GetTicketApi {
  static Future<Ticket> getAllTickets(String id_family) async {
    log("ticket ap--------i");
    final token = await SharedPrefernce.getToken("token");
    log("$token");
    final url = await Config.getApiUrl('getElementsByFamily') +
        "/$id_family"; // Utilisation de Config pour obtenir l'URL

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    log("ggggggggggggggggggggggg");

    if (response.statusCode == 200) {
      log(response.body);
      final Map<String, dynamic> responseData = json.decode(response.body);
      return Ticket.fromJson(responseData);
    } else {
      throw Exception('Failed to load tickets');
    }
  }
}
