import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_chat/utils/auth_utils.dart';
import '../chat/grup_chat_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  bool _isLoading = false;
  bool _obscurePassword = true; // Dodano stan dla widoczności hasła

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _signUp(BuildContext context) async {
    // Walidacja nazwy użytkownika
    final String username = usernameController.text;
    if (username.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nazwa użytkownika musi mieć conajmniej 4 znaki")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    final String email = emailController.text;
    final String password = passwordController.text;

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(username);
      AuthUtils.addUserToFirestore(credential.user!.uid, email, username);
      
      while (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = "Hasło jest zbyt słabe";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Konto już istnieje dla tego adresu email";
      } else {
        errorMessage = "Wystąpił błąd podczas rejestracji";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
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
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("Rejestracja"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        hintText: "Wpisz swój email",
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: "Nazwa użytkownika",
                        hintText: "Minimum 4 znaki",
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Hasło",
                        hintText: "Wpisz swoje hasło",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ButtonStyle(
                        padding: const WidgetStatePropertyAll(EdgeInsets.all(15)),
                        backgroundColor: WidgetStatePropertyAll(Colors.blue[700]),
                        foregroundColor: const WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () => _signUp(context),
                      child: const Text("Zarejestruj się"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}