// ignore_for_file: prefer_const_declarations

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';

import '../models/ActivityElment.dart/ActivityEementModel.dart';

class ApiActivityElement {
  static Future<List<ActivityElment>?> fetchMeeting(
      String idElement, String time) async {
    final token = await SharedPrefernce.getToken("token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/get-tasks-360";

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
