import 'package:flutter/material.dart';
import '../widgets/menu_item_widget.dart';
import '../widgets/custom_divider.dart';

import 'change_username_screen.dart';
import 'change_profile_picture_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

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
          'Ustawienia konta',
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
              icon: Icons.person,
              text: 'Zmień nazwę użytkownika',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangeUsernameScreen(),
                  ),
                );
              },
            ),
            const CustomDivider(dividerColor: Color(0xFF2F3A4B)),
            MenuItemWidget(
              icon: Icons.image,
              text: 'Zmień zdjęcie profilowe',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangeProfilePictureScreen(),
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
