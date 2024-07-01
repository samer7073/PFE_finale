import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/login_page.dart';

class ErrorReporter {
  static void handleError(dynamic error, BuildContext context) {
    if (error is UnauthenticatedException) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    } else {
      // Gérer d'autres types d'erreurs ici
      print('An error occurred: $error');
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    }
  }
}

class UnauthenticatedException implements Exception {
  final String message;
  UnauthenticatedException(this.message);

  @override
  String toString() {
    return message;
  }
}
