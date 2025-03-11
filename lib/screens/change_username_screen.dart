import 'package:flutter/material.dart';

class ChangeUsernameScreen extends StatelessWidget {
  const ChangeUsernameScreen({Key? key}) : super(key: key);

  static const Color appBarColor = Color(0xFF1E3A8A);
  static const Color backgroundColor = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Zmień nazwę użytkownika',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const Center(
        child: Text(
          'Tutaj zmień swoją nazwę użytkownika.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
