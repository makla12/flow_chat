import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  static const Color appBarColor = Color(0xFF1E3A8A);
  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color containerColor = Color(0xFF1F2937);
  static const Color dividerColor = Color(0xFF2F3A4B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Powiadomienia',
          style: TextStyle(color: Colors.white),
        ),
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
              _buildMenuItem(Icons.notifications, 'Włącz powiadomienia'),
              _buildMenuItem(Icons.email, 'Powiadomienia e-mail'),
              _buildMenuItem(Icons.sms, 'Powiadomienia SMS'),
              _buildMenuItem(Icons.vibration, 'Wibracje'),
              _buildMenuItem(Icons.do_not_disturb, 'Tryb „Nie przeszkadzać”'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        // TODO: Dodaj funkcję dla każdej opcji powiadomień
      },
    );
  }
}
