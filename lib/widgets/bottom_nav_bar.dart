import 'package:flow_chat/screens/grup_chat_screen.dart';
import 'package:flow_chat/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flow_chat/screens/friends_screen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Color backgroundColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Color dividerColor;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.backgroundColor,
    required this.selectedItemColor,
    required this.unselectedItemColor,
    required this.dividerColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerColor, width: 1)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: backgroundColor,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          currentIndex: currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Teams'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Friends'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          ],
          onTap: (index) {
            if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FriendsScreen()),
              );
            }
            else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FlowChatScreen()),
                );
            }
            else if (index == 0) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            }

          },
        ),
      ),
    );
  }
}
