import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

import '../core/constants/shared/config.dart';
// Importer le fichier de configuration

class ApiChangePassword {
  static Future<int?> changePassword(Map<String, dynamic> data) async {
    final token = await SharedPrefernce.getToken("token");
    final url = await Config.getApiUrl(
        'changePassword'); // Utilisation de Config pour obtenir l'URL
    log(url);

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
      return response.data["message"];
    } catch (e) {
      print('Error while performing change password request: $e');
      // Retourner null en cas d'erreur
      return null;
    }
  }
}
