// lib/services/api_service.dart
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> fetchFamilies() async {
  final token = await SharedPrefernce.getToken("token");
  const String url =
      'https://spherebackdev.cmk.biz:4543/api/mobile/get-families';

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
          'Failed to load modules: Status code ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to load modules: $e');
    return [];
  }
}

Future<List<dynamic>> fetchRelatedModules(int moduleId) async {
  final token = await SharedPrefernce.getToken("token");
  final String url =
      'https://spherebackdev.cmk.biz:4543/api/mobile/get-label-elements-by-family/$moduleId';

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
          'Failed to load related modules: Status code ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to load related modules: $e');
    return [];
  }
}
