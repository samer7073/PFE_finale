// ignore_for_file: prefer_final_fields, prefer_const_constructors

import 'dart:developer';

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    log("isdark dans le Theme Model $_isDarkMode");
    // Vérifie si le mode sombre est activé au démarrage
    _isDarkMode =
        WidgetsBinding.instance!.window.platformBrightness == Brightness.dark;
    log("isdark APRES PRENDRE DE SYSTEME  dans le Theme Model $_isDarkMode");

    // Écoute les changements du mode sombre du téléphone
    WidgetsBinding.instance!.window.onPlatformBrightnessChanged = () {
      _isDarkMode =
          WidgetsBinding.instance!.window.platformBrightness == Brightness.dark;
      notifyListeners();
    };
  }

  get themeMode => null;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
