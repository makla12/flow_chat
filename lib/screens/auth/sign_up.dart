import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_chat/utils/auth_utils.dart';
import '../chat/grup_chat_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key, required this.setThemeMode});
  final Function(ThemeMode) setThemeMode;

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  bool _isLoading = false;
  bool _textIsObscured = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void _signUp(BuildContext context) async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hasła nie są takie same.")),
      );
      return;
    }
    final String email = emailController.text;
    final String password = passwordController.text;
    final String username = usernameController.text;
    if(email.isEmpty || password.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wszystkie pola są wymagane.")),
      );
      return;
    }
    if(username.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nazwa użytkownika musi mieć co najmniej 3 znaki.")),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(username);
      AuthUtils.addUserToFirestore(credential.user!.uid, email, username);
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
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hasło jest za słabe.")));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Istnieje już użytkownik o podanym adresie email."),
          ),
        );
      } else if(e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Niepoprawny format adresu email"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Wystąpił błąd: ${e.message}"),
          ),
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
      appBar: AppBar(
        title: Text("Zarejestruj się"),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
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
                            labelText: "Nazwa",
                            hintText: "Nazwa",
                          ),
                        ),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: "Hasło",
                            hintText: "Hasło",
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _textIsObscured = !_textIsObscured;
                                });
                              },
                              icon: Icon(
                                _textIsObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          obscureText: _textIsObscured,
                        ),
                        TextField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: "Potwierdz hasło",
                            hintText: "Potwierdz hasło",
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _textIsObscured = !_textIsObscured;
                                });
                              },
                              icon: Icon(
                                _textIsObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          obscureText: _textIsObscured,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                          ),
                          onPressed: () => _signUp(context),
                          child: Text("Zarejestruj się"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
