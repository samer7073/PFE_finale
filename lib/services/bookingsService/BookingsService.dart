import 'dart:convert';
import 'dart:developer';
import 'package:flutter_application_stage_project/models/bookings_models/BookingsApiRespose.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

class Bookingsservice {
  static Future<BookingsApiResponse> getAllBookings({int page = 1}) async {
    log("Fetching tickets from API");
    final token = await SharedPrefernce.getToken("token");
    log("Token: $token");

    final baseUrl = await Config.getApiUrl('getElementsByFamily');
    final url = "$baseUrl/8?page=$page&limit=10";

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
      return BookingsApiResponse.fromJson(responseData);
    } else {
      log("Failed to load tickets: ${response.statusCode}");
      throw Exception('Failed to load tickets');
    }
  }
}