import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  _NotificationsSettingsScreenState createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool isLightMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Wczytanie ustawień trybu jasnego
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLightMode = prefs.getBool('isLightMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ustawienia kolorów zależnie od trybu jasnego
    Color backgroundColor =
        isLightMode ? Colors.white : const Color(0xFF0F172A);
    Color appBarColor = isLightMode ? Colors.blueGrey : const Color(0xFF1E3A8A);
    Color containerColor =
        isLightMode ? Colors.grey.shade200 : const Color(0xFF1F2937);
    Color dividerColor = isLightMode ? Colors.grey : const Color(0xFF2F3A4B);
    Color textColor = isLightMode ? Colors.black : Colors.white;
    Color iconColor = isLightMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Powiadomienia', style: TextStyle(color: textColor)),
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
                Icons.notifications_active,
                'Włącz powiadomienia',
                iconColor,
                textColor,
                dividerColor,
              ),
              _buildMenuItem(
                Icons.email,
                'Powiadomienia e-mail',
                iconColor,
                textColor,
                dividerColor,
              ),
              _buildMenuItem(
                Icons.sms,
                'Powiadomienia SMS',
                iconColor,
                textColor,
                dividerColor,
              ),
              _buildMenuItem(
                Icons.vibration,
                'Wibracje',
                iconColor,
                textColor,
                dividerColor,
              ),
              _buildMenuItem(
                Icons.do_not_disturb,
                'Tryb „Nie przeszkadzać”',
                iconColor,
                textColor,
                dividerColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    Color iconColor,
    Color textColor,
    Color dividerColor,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(title, style: TextStyle(color: textColor)),
          trailing: Switch(
            value: false, // Tutaj można dodać logikę obsługi zmiany stanu
            onChanged: (bool value) {},
            activeColor: Colors.blue,
          ),
        ),
        Divider(color: dividerColor, height: 1),
      ],
    );
  }
}
