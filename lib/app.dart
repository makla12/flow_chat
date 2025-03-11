import 'package:flutter/material.dart';
import 'screens/settings_screen.dart';

class FlowChatApp extends StatelessWidget {
  const FlowChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const FlowChatScreen(),
    );
  }
}
