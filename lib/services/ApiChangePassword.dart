import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

class ApiChangePasword {
  static Future<int?> ChangePassword(Map<String, dynamic> data) async {
    final token = await SharedPrefernce.getToken("token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/change-password";

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
      print('Error while performing field post request: $e');
      // Retourner null en cas d'erreur
      return null;
    }
  }
}
