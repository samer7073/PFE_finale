import 'dart:convert';
import 'dart:developer';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import '../core/constants/shared/config.dart';
import '../models/TaskpiModel.dart';
import '../screens/error_reporter.dart';
// Importez la configuration

class ApiTaskKpi {
  static Future<TaskKpiModel> getApiResponse(
    String start,
    String end,
  ) async {
    log("Fetching data from API");
    final token = await SharedPrefernce.getToken("token");
    log("Token: $token");

    final url = await Config.getApiUrl("tasksKpi");
    final fullUrl = '$url?start=$start&end=$end'; // Ajoutez les paramètres à l'URL
    log("urlKpi: $fullUrl");

    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        log(response.body);
        final Map<String, dynamic> responseData = json.decode(response.body);
        return TaskKpiModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw UnauthenticatedException('Token expired or invalid');
      } else {
        throw Exception('Failed to load task kpi');
      }
    } catch (error) {
      ErrorReporter.handleError(
          error, null!); // Gestionnaire d'erreur avec contexte null
      rethrow; // Renvoyer l'erreur pour une gestion ultérieure si nécessaire
    }
  }
}
