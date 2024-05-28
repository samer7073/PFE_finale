import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_stage_project/models/ticket/ticket.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

class GetTicketApi {
  static Future<Ticket> getAllTickets(String id_family) async {
    log("ticket api");
    final token = await SharedPrefernce.getToken("token");
    log("$token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/get-elements-by-family/$id_family";
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
      return Ticket.fromJson(responseData);
    } else {
      throw Exception('Failed to load tickets');
    }
  }
}
