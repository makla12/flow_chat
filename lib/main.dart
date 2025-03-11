import 'package:flutter/material.dart';
import 'screens/friends_screen.dart';

void main() {
  runApp(FlowChatApp());
}

class FlowChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FriendsScreen(),
    );
  }
}
