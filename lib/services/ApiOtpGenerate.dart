import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../core/constants/shared/config.dart';
import '../models/login/loginResponse.dart';
// Importez la configuration

class ApiOtpGenrate {
  static Future<int?> OtpGenrate(Map<String, dynamic> data) async {
    final baseUrl = await Config.getApiUrl("otpGenerate");

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
        options: Options(),
      );

      log("Response status: ${response.statusCode}");
      log("${response}");

      // Retourner le code de statut HTTP de la réponse
      return response.statusCode;
    } catch (e) {
      print('Error while performing field post request: $e');
      // Retourner null en cas d'erreur
      return null;
    }
  }

  static Future<LoginClass?> LoginOtp(Map<String, dynamic> data) async {
    final baseUrl = await Config.getApiUrl("loginOtp");

    try {
      final baseOptions = BaseOptions(
        baseUrl: baseUrl,
        contentType: Headers.jsonContentType,
        validateStatus: (int? status) {
          return status != null && status < 500;
        },
      );

      Dio dio = Dio(baseOptions);

      Response response = await dio.post(
        baseUrl,
        data: data, // Directly passing the Map<String, dynamic>
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      log("Response status: ${response.statusCode}");
      log("Response data: ${response.data}");

      if (response.statusCode == 200) {
        return LoginClass.fromJson(response.data as Map<String, dynamic>);
      } else {
        log("Error response: ${response.statusCode} ${response.statusMessage}");
        return null;
      }
    } catch (e) {
      print('Error while performing post request: $e');
      return null;
    }
  }
}
