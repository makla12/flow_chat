import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/chats/friends_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlowChatApp extends StatelessWidget {
  const FlowChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); 
          } else if (snapshot.hasData) {
            return const FriendsScreen(); 
          } else {
            return const WelcomeScreen(); 
          }
        },
      ),
    );
  }
}
