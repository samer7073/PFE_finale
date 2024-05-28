import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

class ApiUpdateStageFamily {
  static Future<int?> fieldPost(String Elment_id, String StageId) async {
    final token = await SharedPrefernce.getToken("token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/update-stage-family";

    try {
      final baseOptions = BaseOptions(
        baseUrl: url,
        contentType: Headers.jsonContentType,
        validateStatus: (int? status) {
          return status != null;
        },
      );

      Dio dio = Dio(baseOptions);

      // Créez FormData avec les éléments nécessaires
      var formData = FormData.fromMap({
        'id_element': Elment_id,
        'new_stage_id': StageId,
      });

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
