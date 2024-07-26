import 'dart:developer';

import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/constants/shared/config.dart';

Future<List<dynamic>> fetchGuests() async {
  final String url = await Config.getApiUrl(
        'fetchGuests',
      ) +
      '/get-guests'; // Utilisation de l'URL définie dans Config.dart
  final token = await SharedPrefernce.getToken("token");
  log(url + "8888888888888888888888888888888888888888");

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception(
          'Failed to load guests: Status code ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to load guests: $e');
    throw e;
  }
}
