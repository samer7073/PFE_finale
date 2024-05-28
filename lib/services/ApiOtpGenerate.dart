// ignore_for_file: prefer_const_declarations

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../models/login/loginResponse.dart';

class ApiOtpGenrate {
  static Future<int?> OtpGenrate(Map<String, dynamic> data) async {
    final url =
        "https://sphereauthbackdev.cmk.biz:4543/index.php/api/mobile/generate-otp";

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
        options: Options(),
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

  static Future<LoginClass?> LoginOtp(Map<String, dynamic> data) async {
    final url =
        "https://sphereauthbackdev.cmk.biz:4543/index.php/api/mobile/login-otp";

    try {
      final baseOptions = BaseOptions(
        baseUrl: url,
        contentType: Headers.jsonContentType,
        validateStatus: (int? status) {
          return status != null && status < 500;
        },
      );

      Dio dio = Dio(baseOptions);

      Response response = await dio.post(
        url,
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
