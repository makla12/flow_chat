import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key, required this.setThemeMode});
  final Function(ThemeMode) setThemeMode;

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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Wygląd'), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildMenuItem(
                'Ustawienia systemowe',
                themeMode == 0,
                () {
                  widget.setThemeMode(ThemeMode.system);
                  setState(() => themeMode = 0);
                },
              ),
              _buildMenuItem(
                'Tryb jasny',
                themeMode == 1,
                () {
                  widget.setThemeMode(ThemeMode.light);
                  setState(() => themeMode = 1);
                },
              ),
              _buildMenuItem(
                'Tryb ciemny',
                themeMode == 2,
                () {
                  widget.setThemeMode(ThemeMode.dark);
                  setState(() => themeMode = 2);
                }, 
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
  ) {
    return ListTile(
      title: Text(title),
      trailing: isSelected ? Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}
