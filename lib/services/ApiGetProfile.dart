// ignore_for_file: prefer_const_declarations

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_application_stage_project/models/profil/Profile.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

class ApiProfil {
  static Future<Profile> getProfil() async {
    log("ticket api");
    final token = await SharedPrefernce.getToken("token");
    log("$token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/profile";
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
      throw Exception('Failed to load tickets');
    }
  }

  static Future<int?> ModifyProfile(Map<String, dynamic> data) async {
    final token = await SharedPrefernce.getToken("token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/edit-profile";

    try {
      final baseOptions = BaseOptions(
        baseUrl: url,
        contentType: Headers.jsonContentType,
        validateStatus: (int? status) {
          return status != null;
        },
      );

      Dio dio = Dio(baseOptions);

      // Créez FormData à partir de la carte de données
      var formData = FormData.fromMap(data);

      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      log("here the response -----  ${response.statusCode}");
      log("${response}");

      // Retourner le code de statut HTTP de la réponse
      return response.statusCode;
    } catch (e) {
      print('Error while performing Modify Profile : $e');
      // Retourner null en cas d'erreur
      return null;
    }
  }
}
