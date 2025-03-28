import 'package:flow_chat/notification_controler.dart';
import 'package:flow_chat/screens/chat/grup_chat_screen.dart';
import 'package:flow_chat/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flow_chat/screens/chat/friends_screen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  final Function(ThemeMode) setThemeMode;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.setThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(width: 1, color: Color(0xFF2F3A4B)))),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Serwery'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Znajomi'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          ],
          onTap: (index) {
            if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => NotificationControler(child: FriendsScreen(setThemeMode: setThemeMode),),
                ),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => NotificationControler(child: FlowChatScreen(setThemeMode: setThemeMode),),
                ),
              );
            } else if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: 
                      (context) => NotificationControler(child: HomeScreen(setThemeMode: setThemeMode),),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
