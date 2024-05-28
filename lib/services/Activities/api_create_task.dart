import 'dart:convert';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

Future<void> createTask(Map<String, dynamic> taskData) async {
  final token = await SharedPrefernce.getToken("token"); 
  final url = Uri.parse('https://spherebackdev.cmk.biz:4543/api/mobile/tasks/create'); // Remplacez 'your_api_url' par l'URL de votre API

  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final body = json.encode(taskData);

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Succès
      print('Task created successfully');
    } else {
      // Erreur
      print('Failed to create task: ${response.statusCode}');
      print('Response body: ${response.body}');
      // Vous pouvez lever une exception ici pour la gestion des erreurs
      throw Exception('Failed to create task');
    }
  } catch (e) {
    // Gestion des erreurs de réseau ou autres
    print('Error occurred: $e');
    // Vous pouvez lever une exception ici pour la gestion des erreurs
    throw Exception('Error occurred while creating task');
  }
}
