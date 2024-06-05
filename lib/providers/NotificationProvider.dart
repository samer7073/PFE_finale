import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationProvider extends ChangeNotifier {
  bool _notification = true;

  bool get notification => _notification;

  set notification(bool value) {
    _notification = value;
    notifyListeners();
  }
}
