import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

import '../core/constants/shared/config.dart';
// Importez la configuration

class ApiUpdateStageFamily {
  static Future<int?> fieldPost(String Element_id, String StageId) async {
    final token = await SharedPrefernce.getToken("token");

    final baseUrl = await Config.getApiUrl("updateStageFamily");

    try {
      final baseOptions = BaseOptions(
        baseUrl: baseUrl,
        contentType: Headers.jsonContentType,
        validateStatus: (int? status) {
          return status != null;
        },
      );

      Dio dio = Dio(baseOptions);

      // Créez FormData avec les éléments nécessaires
      var formData = FormData.fromMap({
        'id_element': Element_id,
        'new_stage_id': StageId,
      });

      Response response = await dio.post(
        baseUrl,
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
