import 'package:flow_chat/screens/chat/grup_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_chat/utils/auth_utils.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key, required this.setThemeMode});
  final Function(ThemeMode) setThemeMode;

  @override
  LogInState createState() => LogInState();
}

class LogInState extends State<LogIn> {
  bool _isLoading = false;
  bool _textIsObscured = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _logIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final String email = emailController.text;
    final String password = passwordController.text;
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      AuthUtils.addUserToFirestore(credential.user!.uid, credential.user!.email!, credential.user!.displayName!);
      AuthUtils.onUserLogin();
      if(!context.mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(setThemeMode: widget.setThemeMode,)),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if(!context.mounted) return;
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Niepoprawny email lub hasło")),
        );
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Niepoprawny format adresu email")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Wystąpił błąd: ${e.message}")),
        );
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
      appBar: AppBar(
        backgroundColor: Color(0xFF0F172A),
        title: Text("Zaloguj"),
      ),
      body: _isLoading
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
                  suffixIcon: IconButton(onPressed: (){setState(() { _textIsObscured = !_textIsObscured; });}, icon: Icon(_textIsObscured ? Icons.visibility : Icons.visibility_off))
                  
                ),
                obscureText: _textIsObscured,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                  backgroundColor: WidgetStatePropertyAll(Color(0xFF3B82F6)),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
                onPressed: () => _logIn(context),
                child: Text("Zaloguj"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
