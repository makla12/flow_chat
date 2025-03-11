import 'package:flutter/material.dart';
import '../widgets/menu_item_widget.dart';
import '../widgets/custom_divider.dart';
import 'change_email_screen.dart';
import 'change_password_screen.dart';

class PrivacyAndSecurityScreen extends StatelessWidget {
  const PrivacyAndSecurityScreen({Key? key}) : super(key: key);

  static const Color appBarColor = Color(0xFF1E3A8A);
  static const Color backgroundColor = Color(0xFF0F172A);

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
          'Prywatność i bezpieczeństwo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MenuItemWidget(
              icon: Icons.email,
              text: 'Zmień email',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangeEmailScreen(),
                  ),
                );
              },
            ),
            const CustomDivider(dividerColor: Color(0xFF2F3A4B)),
            MenuItemWidget(
              icon: Icons.lock,
              text: 'Zmień hasło',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
