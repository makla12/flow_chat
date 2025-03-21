import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  AppearanceScreenState createState() => AppearanceScreenState();
}

class AppearanceScreenState extends State<AppearanceScreen> {
  int themeMode = 0; // 0 - System, 1 - Jasny, 2 - Ciemny

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      themeMode = prefs.getInt('themeMode') ?? 0;
    });
  }

  Future<void> _saveThemeMode(int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', value);
  }

  void setThemeMode(int mode) {
    setState(() {
      themeMode = mode;
    });
    _saveThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        themeMode == 2 ? const Color(0xFF0F172A) : Colors.white;
    Color containerColor =
        themeMode == 2 ? const Color(0xFF1F2937) : Colors.grey.shade200;
    Color textColor = themeMode == 2 ? Colors.white : Colors.black;
    Color iconColor = themeMode == 2 ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor:
            themeMode == 2 ? const Color(0xFF1E3A8A) : Colors.blueGrey,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Wygląd', style: TextStyle(color: textColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildMenuItem(
                'Ustawienia systemowe',
                themeMode == 0,
                () => setThemeMode(0),
                textColor,
              ),
              _buildMenuItem(
                'Tryb jasny',
                themeMode == 1,
                () => setThemeMode(1),
                textColor,
              ),
              _buildMenuItem(
                'Tryb ciemny',
                themeMode == 2,
                () => setThemeMode(2),
                textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    bool isSelected,
    VoidCallback onTap,
    Color textColor,
  ) {
    return ListTile(
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: isSelected ? Icon(Icons.check, color: textColor) : null,
      onTap: onTap,
    );
  }
}
