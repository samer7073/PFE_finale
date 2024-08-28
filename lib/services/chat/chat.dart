



import 'dart:convert';

import 'package:flutter_application_stage_project/core/constants/shared/config.dart';
import 'package:flutter_application_stage_project/models/chatUserModel/chatUserModel.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;


class ChatRomm {
  static Future<List<ChatUser>> fetchAllUsers() async {
   
    final token = await SharedPrefernce.getToken("token");
     final baseUrl = await Config.getApiUrl('allUsers');
    

   final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (jsonResponse['success'] == true) {
      final List<dynamic> usersJson = jsonResponse['all_users'];
      return usersJson.map((userJson) => ChatUser.fromJson(userJson)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des utilisateurs.');
    }
  } else {
    throw Exception('Erreur de connexion : ${response.statusCode}');
  }
}
}