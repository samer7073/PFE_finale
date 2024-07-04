import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

import '../core/constants/shared/config.dart';
// Importer Config pour utiliser les URLs

class ApiFieldPost {
  static Future<int?> fieldPost(Map<String, dynamic> data, int familyId) async {
    final token = await SharedPrefernce.getToken("token");
    final apiUrl = await Config.getApiUrl(
        "createElementUrl"); // Utilisation de l'URL à partir de Config

    try {
      // Ajouter le familyId au corps de la requête
      data['family_id'] = familyId;

      final baseOptions = BaseOptions(
        baseUrl: apiUrl,
        contentType: Headers.jsonContentType,
        validateStatus: (int? status) {
          return status != null;
        },
      );

      Dio dio = Dio(baseOptions);

      // Créez FormData à partir de la carte de données
      var formData = FormData.fromMap(data);

      Response response = await dio.post(
        apiUrl,
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
      print('Error while performing field post request: $e');
      // Retourner null en cas d'erreur
      return null;
    }
  }

  static Future<int?> fieldUpdatePost(
      Map<String, dynamic> data, String elementId) async {
    final token = await SharedPrefernce.getToken("token");
    final apiUrl = await Config.getApiUrl("updateElementUrl");
    // Utilisation de l'URL à partir de Config
    log("api url $apiUrl");

    try {
      final baseOptions = BaseOptions(
        baseUrl: apiUrl,
        contentType: Headers.jsonContentType,
        validateStatus: (int? status) {
          return status != null;
        },
      );

      Dio dio = Dio(baseOptions);

      // Créez FormData à partir de la carte de données
      var formData = FormData.fromMap(data);

      Response response = await dio.post(
        apiUrl + '/$elementId',
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
      log('Error while performing field update post request: $e');
      // Retourner null en cas d'erreur
      return null;
    }
  }
}
