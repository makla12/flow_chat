import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController emailController = TextEditingController();

  bool _isLoading = false;

  void _resetPassword () async {
    setState(() {
      _isLoading = true;
    });
    if(emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wpisz adres e-mail')));
    } else {
      try{
        await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Na maila został wysłany link do zresetowania hasła')));
      } on FirebaseAuthException catch(e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Wystąpił błąd')));
      } catch(e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wystąpił błąd')));
      }
    }
    setState(() {
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resetowanie hasła'),
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(),) : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Adres e-mail',
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetPassword,
              child: Text('Wyślij link do zresetowania hasła'),
            ),
          ],
        ),
      ),
    );
  }
}