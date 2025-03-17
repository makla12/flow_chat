import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isLightMode = false;
  double _fontSize = 14.0;
  Color _accentColor = Colors.blue;

  ThemeProvider() {
    _loadPreferences(); // Automatyczne ładowanie po uruchomieniu
  }

  bool get isLightMode => _isLightMode;
  double get fontSize => _fontSize;
  Color get accentColor => _accentColor;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isLightMode = prefs.getBool('isLightMode') ?? false;
    _fontSize = prefs.getDouble('fontSize') ?? 14.0;
    _accentColor = Color(prefs.getInt('accentColor') ?? Colors.blue.value);
    notifyListeners();
  }

  Future<void> toggleLightMode() async {
    _isLightMode = !_isLightMode;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLightMode', _isLightMode);
    notifyListeners();
  }

  Future<void> changeFontSize(double newSize) async {
    _fontSize = newSize;
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSize', newSize);
    notifyListeners();
  }

  Future<void> changeAccentColor(Color newColor) async {
    _accentColor = newColor;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('accentColor', newColor.value);
    notifyListeners();
  }
}
