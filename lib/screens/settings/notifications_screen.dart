import 'package:flutter/material.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Powiadomienia'),
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
                Icons.notifications_active,
                'Włącz powiadomienia',
              ),
              _buildMenuItem(
                Icons.email,
                'Powiadomienia e-mail',
              ),
              _buildMenuItem(
                Icons.sms,
                'Powiadomienia SMS',
              ),
              _buildMenuItem(
                Icons.vibration,
                'Wibracje',
              ),
              _buildMenuItem(
                Icons.do_not_disturb,
                'Tryb „Nie przeszkadzać”',
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
  ) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: Switch(
            value: false, // Tutaj można dodać logikę obsługi zmiany stanu
            onChanged: (bool value) {},
            activeColor: Colors.blue,
          ),
        ),
        Divider(height: 1),
      ],
    );
  }
}
