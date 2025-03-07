import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Image(image: AssetImage("images/logo.png"))),
            Expanded(child: Text("Chat with Flow", style: TextStyle(fontSize: 30),))
            
          ],
        ),
      ),
    );
  }
}
