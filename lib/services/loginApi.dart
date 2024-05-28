import 'dart:convert';
import 'dart:developer';

import 'package:flutter_application_stage_project/core/constants/contants.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

import '../models/login/loginResponse.dart';

class LoginApi {
  Future<LoginClass> loginUser(
      String email, String password, String Url) async {
    log("url dans loginUser -------------------------------------" + Url);
    final urlLogin = await SharedPrefernce.getToken("url");
    log("$urlLogin");

    final response = await http.post(
      ConstantesPage(Url).baseUrl,
      //Uri.parse("https://sphereauthbackdev.cmk.biz:4543/index.php/api/mobile/login"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    log(response.statusCode.toString());

    if (response.statusCode == 200) {
      log("retoune 200 -----------------------------------");
      return LoginClass.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      log("${response.statusCode}");
      // Handle non-200 status codes with a user-friendly message
      final errorMessage = _getErrorMessage(response.statusCode, response.body);
      throw LoginException(errorMessage); // Custom exception for login errors
    }
  }

  String _getErrorMessage(int statusCode, String body) {
    String message;
    switch (statusCode) {
      case 400:
        message = 'Bad request: ${_extractErrorFromBody(body)}';
        break;
      case 401:
        message = 'Unauthorized: Invalid email or password.';
        break;
      case 403:
        message =
            'Forbidden: You may not have permission to access this resource.';
        break;
      default:
        message =
            'An error occurred (code: $statusCode). Please try again later.';
    }
    return message;
  }

  String _extractErrorFromBody(String body) {
    try {
      final json = jsonDecode(body);
      if (json['error'] != null) {
        return json['error'] as String;
      }
      return 'Unknown error';
    } catch (e) {
      return 'Unknown error';
    }
  }
}

class LoginException implements Exception {
  final String message;

  LoginException(this.message);
}
