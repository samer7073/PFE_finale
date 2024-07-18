import 'dart:developer';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/constants/shared/config.dart';
import '../models/KanbanModels/KanbanResponse.dart';
// Importez la configuration

class GetKanbanApi {
  static Future<KanbanResponse> getKanban(
    String idPipeline,
  ) async {
    log("kanban api");
    final token = await SharedPrefernce.getToken("token");

    final baseUrl = await Config.getApiUrl("kanban");
    final url = "$baseUrl/$idPipeline";
    log(url);

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      log("kanban" + response.body);
      final Map<String, dynamic> responseData = json.decode(response.body);
      return KanbanResponse.fromJson(responseData);
    } else {
      throw Exception('Failed to load kanban data');
    }
  }
}
