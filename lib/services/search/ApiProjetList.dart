import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../models/ticket/ticketData.dart';
import '../sharedPreference.dart';

class ApiProjectList {
  Future<List<TicketData>> getProjectList({String? query}) async {
    List<TicketData> results = [];
    log("ticket api");
    final token = await SharedPrefernce.getToken("token");
    log("$token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/get-elements-by-family/6";
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
        if (query != null) {
          results = results
              .where((element) => element.reference
                  .toLowerCase()
                  .contains((query.toLowerCase())))
              .toList();
        }
      } else {
        log("fetch error: ${response.statusCode}");
      }
    } on Exception catch (e) {
      log('error: $e');
    }
    return results;
  }
}
