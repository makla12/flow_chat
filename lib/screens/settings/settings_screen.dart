import 'package:flow_chat/screens/chat/notifications.dart';
import 'package:flow_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/menu_item_widget.dart';
import '../../widgets/custom_divider.dart';
import 'profile_screen.dart';
import 'privacy_and_security_screen.dart';
import 'notifications_screen.dart';
import 'appearance_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FlowChatScreen extends StatefulWidget {
  const FlowChatScreen({super.key});

  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color appBarColor = Color(0xFF1E3A8A);
  static const Color containerColor = Color(0xff211f26);
  static const Color dividerColor = Color(0xff4F4F4F);
  static const Color logoutColor = Color.fromARGB(255, 253, 63, 60);

  @override
  State<FlowChatScreen> createState() => _FlowChatScreenState();
}

class _FlowChatScreenState extends State<FlowChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlowChatScreen.backgroundColor,
      appBar: AppBar(
        backgroundColor: FlowChatScreen.appBarColor,
        title: const Text('FlowChat', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              color: FlowChatScreen.containerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [_buildMenuItems(context)],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
        backgroundColor: FlowChatScreen.backgroundColor,
        selectedItemColor: const Color.fromARGB(255, 63, 146, 255),
        unselectedItemColor: Colors.white70,
        dividerColor: FlowChatScreen.dividerColor,
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        MenuItemWidget(
          icon: Icons.person,
          text: 'Pokaż profil',
          onTap: () => _navigateTo(context, const ProfileScreen()),
        ),
        const CustomDivider(dividerColor: FlowChatScreen.dividerColor),
        MenuItemWidget(
          icon: Icons.security,
          text: 'Prywatność i bezpieczeństwo',
          onTap: () => _navigateTo(context, const PrivacyAndSecurityScreen()),
        ),
        const CustomDivider(dividerColor: FlowChatScreen.dividerColor),
        MenuItemWidget(
          icon: Icons.notifications,
          text: 'Powiadomienia',
          onTap:
              () => _navigateTo(context, const NotificationsSettingsScreen()),
        ),
        const CustomDivider(dividerColor: FlowChatScreen.dividerColor),
        MenuItemWidget(
          icon: Icons.star,
          text: 'Motyw',
          onTap: () => _navigateTo(context, const AppearanceScreen()),
        ),
        const CustomDivider(dividerColor: FlowChatScreen.dividerColor),
        MenuItemWidget(
          icon: Icons.logout,
          text: 'Wyloguj się',
          color: FlowChatScreen.logoutColor,
          onTap: () {
            FirebaseMessaging.instance.unsubscribeFromTopic(
              FirebaseAuth.instance.currentUser!.uid,
            );
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            );
          },
        ),
      ],
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
