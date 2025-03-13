import 'package:flow_chat/screens/chat/grup_chat_screen.dart';
import 'package:flow_chat/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:flow_chat/screens/auth/sign_up.dart';
import 'package:flow_chat/screens/auth/log_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void _signInWithGoogle(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userCredential = await signInWithGoogle();
      AuthUtils.addUserToFirestore(userCredential.user!.uid, userCredential.user!.email!, userCredential.user!.displayName!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
      while(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
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
                    OutlinedButton(
                      style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () => _signInWithGoogle(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(image: AssetImage("images/googleIcon.png"), width: 24),
                          SizedBox(width: 10),
                          Text("Sign in with Google"),
                      ],),
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
