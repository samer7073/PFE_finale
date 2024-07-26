import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
// Importer le fichier de configuration

import '../core/constants/shared/config.dart';
import '../models/ActivityElment.dart/ActivityEementModel.dart';

class ApiActivityElement {
  static Future<List<ActivityElment>?> fetchMeeting(
      String idElement, String time) async {
    final token = await SharedPrefernce.getToken("token");

    final url = await Config.getApiUrl(
      'getTasks360',
    ); // Utilisation de Config pour obtenir l'URL
    log(url);
    try {
      Map<String, dynamic> data = {'id': idElement, 'time': time};

      final baseOptions = BaseOptions(
        baseUrl: url,
        contentType: Headers.jsonContentType,
        validateStatus: (int? status) {
          return status != null;
        },
      );

      Dio dio = Dio(baseOptions);

      var formData = FormData.fromMap(data);

      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;
        final List<dynamic> dataList = jsonData['data'];
        log("-----------------$jsonData['data']");
        List<ActivityElment> activityElements =
            dataList.map((json) => ActivityElment.fromJson(json)).toList();
        return activityElements;
      } else {
        return null;
      }
    } catch (e) {
      print('Error while fetching meeting: $e');
      return null;
    }
  }
}
