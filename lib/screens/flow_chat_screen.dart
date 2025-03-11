import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/menu_item_widget.dart';
import '../widgets/custom_divider.dart';

class FlowChatScreen extends StatelessWidget {
  const FlowChatScreen({Key? key}) : super(key: key);

  // Definicje kolorów
  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color appBarColor = Color(0xFF1E3A8A);
  static const Color containerColor = Color(0xFF1F2937);
  static const Color dividerColor = Color(0xFF2F3A4B);
  static const Color logoutColor = Color(0xFFE53935);

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
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      // Główna część ekranu
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
                MenuItemWidget(icon: Icons.person, text: 'Pokaż profil'),
                const CustomDivider(dividerColor: dividerColor),
                MenuItemWidget(icon: Icons.settings, text: 'Ustawienia konta'),
                const CustomDivider(dividerColor: dividerColor),
                MenuItemWidget(
                  icon: Icons.security,
                  text: 'Prywatność i bezpieczeństwo',
                ),
                const CustomDivider(dividerColor: dividerColor),
                MenuItemWidget(
                  icon: Icons.notifications,
                  text: 'Powiadomienia',
                ),
                const CustomDivider(dividerColor: dividerColor),
                MenuItemWidget(icon: Icons.star, text: 'Wygląd'),
                const CustomDivider(dividerColor: dividerColor),
                MenuItemWidget(
                  icon: Icons.logout,
                  text: 'Wyloguj się',
                  color: logoutColor,
                ),
              ],
            ),
          ),
        ),
      ),
      // Dolne menu
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2, // Podświetlamy przycisk "Menu"
        backgroundColor: backgroundColor,
        selectedItemColor: appBarColor,
        unselectedItemColor: Colors.white70,
        dividerColor: dividerColor,
      ),
    );
  }
}
