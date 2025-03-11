import 'package:flutter/material.dart';
import 'package:flow_chat/screens/sign_up.dart';
import 'package:flow_chat/screens/log_in.dart';
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),

      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image(image: AssetImage("images/logo.png"), width: 128),
                
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Chat with ",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Flow",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 20,
                  children: [
                    FilledButton(
                      style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
                        backgroundColor: WidgetStatePropertyAll(
                          Color(0xFF3B82F6),
                        ),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LogIn()));
                      },
                      child: Text("Log in"),
                    ),
                    FilledButton(
                      style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
                        backgroundColor: WidgetStatePropertyAll(
                          Color(0xFF3B82F6),
                        ),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: Text("Sign up"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
