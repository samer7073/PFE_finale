import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../core/constants/shared/config.dart';
import '../models/login/loginResponse.dart';
// Importez la configuration

class LoginApi {
  Future<LoginClass> loginUser(
      String email, String password, bool isProd) async {
    final url = await Config.getApiUrl("login",);
    log("URL dans loginUser ------------------------------------- $url");

    final response = await http.post(
      Uri.parse(url),
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
      log("retourne 200 -----------------------------------");
      return LoginClass.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      log("${response.statusCode}");
      final errorMessage = _getErrorMessage(response.statusCode, response.body);
      throw LoginException(errorMessage);
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
