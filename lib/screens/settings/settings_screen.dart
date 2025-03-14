import 'package:flow_chat/screens/chat/notifications.dart';
import 'package:flow_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/menu_item_widget.dart';
import '../../widgets/custom_divider.dart';

import 'profile_screen.dart';
import 'account_settings_screen.dart';
import 'privacy_and_security_screen.dart';
import 'notifications_screen.dart';
import 'appearance_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlowChatScreen extends StatelessWidget {
  const FlowChatScreen({Key? key}) : super(key: key);

  // Definicje kolorów
  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color appBarColor = Color(0xFF1E3A8A);
  static const Color containerColor = Color(0xff211f26);
  static const Color dividerColor = Color(0xff4F4F4F);
  static const Color logoutColor = Color.fromARGB(255, 253, 63, 60);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // Pasek górny
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text('FlowChat', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(),
                ), // Poprawiona nawigacja
              );
            },
          ),
        ],
      ),
      // Główna część ekranu z menu
      body: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 16),
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MenuItemWidget(
                  icon: Icons.person,
                  text: 'Pokaż profil',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                const CustomDivider(dividerColor: dividerColor),
                MenuItemWidget(
                  icon: Icons.settings,
                  text: 'Ustawienia konta',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountSettingsScreen(),
                      ),
                    );
                  },
                ),
                const CustomDivider(dividerColor: dividerColor),
                MenuItemWidget(
                  icon: Icons.security,
                  text: 'Prywatność i bezpieczeństwo',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyAndSecurityScreen(),
                      ),
                    );
                  },
                ),
                const CustomDivider(dividerColor: dividerColor),
                MenuItemWidget(
                  icon: Icons.notifications,
                  text: 'Powiadomienia',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsSettingsScreen(),
                      ),
                    );
                  },
                ),
                const CustomDivider(dividerColor: dividerColor),
                MenuItemWidget(
                  icon: Icons.star,
                  text: 'Wygląd',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppearanceScreen(),
                      ),
                    );
                  },
                ),
                const CustomDivider(dividerColor: dividerColor),
                MenuItemWidget(
                  icon: Icons.logout,
                  text: 'Wyloguj się',
                  color: logoutColor,
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      // Dolna nawigacja (Friends, Teams, Menu)
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2, // Podświetlenie przycisku "Menu"
        backgroundColor: backgroundColor,
        selectedItemColor: const Color.fromARGB(255, 63, 146, 255),
        unselectedItemColor: Colors.white70,
        dividerColor: dividerColor,
      ),
    );
  }
}
