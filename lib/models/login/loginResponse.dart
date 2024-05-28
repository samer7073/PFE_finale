import 'dart:ffi';

import 'package:flutter_application_stage_project/models/login/token.dart';
import 'package:flutter_application_stage_project/models/login/user.dart';

class LoginClass {
  final bool success;
  final User user;
  final Token token;
  LoginClass({
    required this.success,
    required this.user,
    required this.token,
  });
  factory LoginClass.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('success') &&
        json.containsKey('user') &&
        json.containsKey('token')) {
      bool success = json['success'];
      User user = User.fromJson(json['user']);
      Token token = Token.fromJson(json['token']);
      return LoginClass(success: success, user: user, token: token);
    } else {
      throw FormatException("Failed to load user . required keys are missing");
    }
  }
}
