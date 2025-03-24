import 'package:flow_chat/screens/chat/notifications.dart';
import 'package:flow_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/menu_item_widget.dart';
import '../../widgets/custom_divider.dart';
import 'profile_screen.dart';
import 'privacy_and_security_screen.dart';
import 'appearance_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FlowChatScreen extends StatefulWidget {
  const FlowChatScreen({super.key, required this.setThemeMode});
  final Function(ThemeMode) setThemeMode;

  @override
  State<FlowChatScreen> createState() => _FlowChatScreenState();
}

class _FlowChatScreenState extends State<FlowChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlowChat'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
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
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [_buildMenuItems(context, widget.setThemeMode)],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
        setThemeMode: widget.setThemeMode,
      ),
    );
  }

  Widget _buildMenuItems(
    BuildContext context,
    Function(ThemeMode) setThemeMode,
  ) {
    return Column(
      children: [
        MenuItemWidget(
          icon: Icons.person,
          text: 'Pokaż profil',
          onTap: () => _navigateTo(context, const ProfileScreen()),
        ),
        const CustomDivider(),
        MenuItemWidget(
          icon: Icons.security,
          text: 'Prywatność i bezpieczeństwo',
          onTap: () => _navigateTo(context, const PrivacyAndSecurityScreen()),
        ),
        const CustomDivider(),
        MenuItemWidget(
          icon: Icons.star,
          text: 'Motyw',
          onTap:
              () => _navigateTo(
                context,
                AppearanceScreen(setThemeMode: setThemeMode),
              ),
        ),
        const CustomDivider(),
        MenuItemWidget(
          icon: Icons.logout,
          text: 'Wyloguj się',
          color: Colors.red,
          onTap: () {
            FirebaseMessaging.instance.unsubscribeFromTopic(
              FirebaseAuth.instance.currentUser!.uid,
            );
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomeScreen(setThemeMode: setThemeMode),
              ),
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
