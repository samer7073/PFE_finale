import 'dart:developer';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/KanbanModels/KanbanResponse.dart';

class GetKanbanApi {
  static Future<KanbanResponse> getKanban(String idPipeline) async {
    log("kanban api");
    final token = await SharedPrefernce.getToken("token");

    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/kanban-by-stage/$idPipeline";
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
