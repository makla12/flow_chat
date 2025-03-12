import 'package:flow_chat/screens/chats/grup_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_chat/utils/auth_utils.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  LogInState createState() => LogInState();
}
class LogInState extends State<LogIn> {
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _logIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final String email = emailController.text;
    final String password = passwordController.text;
    try{
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      AuthUtils.addUserToFirestore(credential.user!.uid, credential.user!.email!, credential.user!.displayName!);
      while(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
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
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Color(0xFF0F172A),
        title: Text("Log in"),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
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
