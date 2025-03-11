import 'package:flow_chat/screens/grup_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogIn extends StatelessWidget {
  LogIn({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _logIn(BuildContext context) async {
    final String email = emailController.text;
    final String password = passwordController.text;
    print("Email: $email, Password: $password");
    try{
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      print(credential.user);
    } on FirebaseAuthException catch (e) {
      if(e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No user found for that email."))
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Wrong password provided for that user."))
        );
      }
    } catch (e) {
      print("Error: $e");
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Color(0xFF0F172A),
        title: Text("Log in"),
      ),
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Email",
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Password",
                    ),
                    obscureText: true,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                      backgroundColor: WidgetStatePropertyAll(Color(0xFF3B82F6)),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: () => _logIn(context),
                    child: Text("Log in")
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
