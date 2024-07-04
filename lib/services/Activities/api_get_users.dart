import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/constants/shared/config.dart';

Future<List<dynamic>> fetchUsers() async {
  final String url = await Config.getApiUrl(
        'fetchUsers',
      ) +
      '/get-users'; // Utilisation de l'URL définie dans Config.dart
  final token = await SharedPrefernce.getToken("token");

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
          'Failed to load users: Status code ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to load users: $e');
    throw e;
  }
}
