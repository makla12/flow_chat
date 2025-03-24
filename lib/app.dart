import 'package:flow_chat/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/chat/grup_chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlowChatApp extends StatefulWidget {
  const FlowChatApp({super.key});

  @override
  State<FlowChatApp> createState() => _FlowChatAppState();
}

class _FlowChatAppState extends State<FlowChatApp> {
  ThemeMode themeMode = ThemeMode.system;

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    });
  }

  void _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', mode.index);
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      themeMode = mode;
    });
    _saveThemeMode(mode);
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[200]
        ),
        cardColor: Colors.grey[400],
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0F172A),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A)
        ),
        dividerColor: Color(0xFF2F3A4B),
        cardColor: Colors.grey[900]
      ),

      themeMode: themeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); 
          } else if (snapshot.hasData) {
            AuthUtils.onUserLogin();
            return HomeScreen(setThemeMode: setThemeMode,); 
          } else {
            return WelcomeScreen(setThemeMode: setThemeMode,); 
          }
        },
      ),
    );
  }
}
