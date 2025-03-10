import 'package:flutter/material.dart';

void main() {
  runApp(const FlowChatApp());
}

class FlowChatApp extends StatelessWidget {
  const FlowChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F172A), // główne tło
      ),
      home: const FlowChatScreen(),
    );
  }
}

class FlowChatScreen extends StatelessWidget {
  const FlowChatScreen({Key? key}) : super(key: key);

  // Definicje kolorów
  static const Color backgroundColor = Color(0xFF0F172A); // tło aplikacji
  static const Color appBarColor = Color(0xFF1E3A8A); // pasek górny
  static const Color containerColor = Color(0xFF1F2937); // kontener menu
  static const Color dividerColor = Color(
    0xFF2F3A4B,
  ); // linia między elementami
  static const Color logoutColor = Color(0xFFE53935); // czerwony (Wyloguj się)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // Pasek górny
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text(
          'FlowChat',
          style: TextStyle(color: Colors.white), // <-- Biały tytuł
        ),
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
                _buildMenuItem(icon: Icons.person, text: 'Pokaż profil'),
                _buildDivider(),
                _buildMenuItem(icon: Icons.settings, text: 'Ustawienia konta'),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.security,
                  text: 'Prywatność i bezpieczeństwo',
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.notifications,
                  text: 'Powiadomienia',
                ),
                _buildDivider(),
                _buildMenuItem(icon: Icons.star, text: 'Wygląd'),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.logout,
                  text: 'Wyloguj się',
                  color: logoutColor,
                ),
              ],
            ),
          ),
        ),
      ),

      // Dodajemy szarą kreskę i dopiero pod nią BottomNavigationBar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerColor, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: backgroundColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: 1, // np. 1, jeśli 'Friends' jest wybrane
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Teams'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Friends'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          ],
        ),
      ),
    );
  }

  // Widget menuItem
  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    Color color = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      onTap: () {
        // Logika po kliknięciu
      },
    );
  }

  // Widget do tworzenia linii rozdzielającej elementy
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: dividerColor,
    );
  }
}
