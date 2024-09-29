import 'dart:convert';
import 'dart:developer';

import 'package:flutter_application_stage_project/models/note_models/note.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/shared/config.dart';
import '../sharedPreference.dart';

class NoteService {
  static Future<List<Note>> getAllNotes({int page = 1,String search = ''}) async {
    log("Fetching Notes from API");
    final token = await SharedPrefernce.getToken("token");
    log("Token: $token");

    // Utilisation de Config pour obtenir l'URL
    final baseUrl = await Config.getApiUrl('note');
    final url = "$baseUrl?page=$page";
    log(url);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      log("Response: ${response.body}");
      final Map<String, dynamic> responseData = json.decode(response.body);
      return parseNotes(responseData);
    } else {
      log("Failed to load Notes: ${response.statusCode}");
      throw Exception('Failed to load Notes');
    }
  }

  static List<Note> parseNotes(Map<String, dynamic> responseBody) {
    final notesData = responseBody['data']['data'] as List;
    return notesData.map<Note>((json) => Note.fromJson(json)).toList();
  }
}