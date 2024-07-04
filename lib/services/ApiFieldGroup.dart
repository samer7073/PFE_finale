// ignore_for_file: prefer_const_declarations

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

// Importez votre fichier config.dart ici
import '../core/constants/shared/config.dart';
import '../models/fields/datafieldgroupresponse.dart';
import '../models/fields/datafieldsresponse.dart';

class ApiFieldGroup {
  static Future<DataFieldRespone> getGroupfields(String family_id) async {
    final token = await SharedPrefernce.getToken("token");
    final apiUrl =await Config.getApiUrl(
        "groupFieldsUrl"); // Utilisation de Config pour obtenir l'URL
    final url = "$apiUrl/$family_id";

    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      log(responseData.toString());
      return DataFieldRespone.fromJson(responseData['data']);
    } else {
      throw Exception('Failed to load fields');
    }
  }
}
