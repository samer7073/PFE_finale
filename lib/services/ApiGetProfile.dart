import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_application_stage_project/models/profil/Profile.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

import '../core/constants/shared/config.dart';
// Importez la configuration

class ApiProfil {
  static Future<Profile> getProfil() async {
    log("Fetching data from API");
    final token = await SharedPrefernce.getToken("token");

    

    final baseUrl = await Config.getApiUrl("profile");
    log("profile ${baseUrl}");
    final url = "$baseUrl";
    log("Profile"+url);

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

      // Accéder à la clé "data" et créer un objet Profile
      final Map<String, dynamic> data = responseData['data'];
      return Profile.fromJson(data);
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  static Future<int?> modifyProfile(Map<String, dynamic> data) async {
    final token = await SharedPrefernce.getToken("token");

    final baseUrl = await Config.getApiUrl("modifyProfile");
    log("baseurl" + baseUrl);

    try {
      final baseOptions = BaseOptions(
        baseUrl: baseUrl,
        contentType: Headers.jsonContentType,
        validateStatus: (int? status) {
          return status != null;
        },
      );

      Dio dio = Dio(baseOptions);

      // Créez FormData à partir de la carte de données
      var formData = FormData.fromMap(data);

      Response response = await dio.post(
        baseUrl,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      log("Response status: ${response.statusCode}");
      log("Response data: ${response}");

      // Retourner le code de statut HTTP de la réponse
      return response.statusCode;
    } catch (e) {
      print('Error while performing Modify Profile : $e');
      // Retourner null en cas d'erreur
      return null;
    }
  }
}
