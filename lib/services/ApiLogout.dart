import 'dart:convert';
import 'dart:developer';
import 'package:flutter_application_stage_project/services/fcm/FirebaseMessagingService.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

import '../core/constants/shared/config.dart';
// Importez la configuration

class ApiLogout {
  static Future<String> logOut() async {
    log("dans api logout");
    // Appel de la méthode pour supprimer le FCM token du serveur

    final token = await SharedPrefernce.getToken("token");
     await FirebaseMessagingService().deleteTokenFromServer(token.toString());
    final baseUrl = await Config.getApiUrl("logout");
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    log(response.statusCode.toString());
    log(response.body.toString());
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      log(responseData.toString());
      return responseData['message'];
    } else {
      throw Exception('Failed to load fields');
    }
  }
}
