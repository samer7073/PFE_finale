import 'package:flutter/material.dart';

class stagechangeprovider extends ChangeNotifier {
  bool _needsRefresh = false;

  bool get needsRefresh => _needsRefresh;

  void setNeedsRefresh(bool value) {
    _needsRefresh = value;
    notifyListeners();
  }
}
