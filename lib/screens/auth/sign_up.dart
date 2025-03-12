import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_chat/utils/auth_utils.dart';
import '../chats/grup_chat_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  SignUpState createState() => SignUpState();
}
class SignUpState extends State<SignUp> {
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _signUp(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final String email = emailController.text;
    final String password = passwordController.text;
    final String username = usernameController.text;
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(username);
      AuthUtils.addUserToFirestore(credential.user!.uid, email, username);
      while(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("The password provided is too weak."))
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("The account already exists for that email."))
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
        title: Text("Sign up"),
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
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  hintText: "Username",
                ),
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
                onPressed: () => _signUp(context),
                child: Text("Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
