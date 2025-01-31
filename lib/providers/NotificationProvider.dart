import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  bool _notification = true;

  bool get notification => _notification;

  set notification(bool value) {
    _notification = value;
    notifyListeners();
  }

  // Méthode pour activer les notifications
  void enableNotifications() {
    _notification = true;
    notifyListeners();
  }

  // Méthode pour désactiver les notifications
  void disableNotifications() {
    _notification = false;
    notifyListeners();
  }
}
