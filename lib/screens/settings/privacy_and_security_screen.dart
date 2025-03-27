import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyAndSecurityScreen extends StatefulWidget {
  const PrivacyAndSecurityScreen({super.key});

  @override
  PrivacyAndSecurityScreenState createState() =>
      PrivacyAndSecurityScreenState();
}

class PrivacyAndSecurityScreenState extends State<PrivacyAndSecurityScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _emailPasswordController =
      TextEditingController();

  final TextEditingController _currentPasswordForPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _loginProvider;
  bool isLightMode = false;

  @override
  void initState() {
    super.initState();
    _checkLoginProvider();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLightMode = prefs.getBool('isLightMode') ?? false;
    });
  }

  Future<void> _checkLoginProvider() async {
    final user = _auth.currentUser;
    if (user != null && user.providerData.isNotEmpty) {
      setState(() {
        _loginProvider = user.providerData.first.providerId;
      });
    }
  }

  Future<void> _reauthenticateUser({String? currentPassword}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        message: 'Użytkownik nie jest zalogowany.',
        code: 'no-user',
      );
    }

    final providerId =
        user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'password';

    if (providerId == 'google.com') {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          message: 'Reautoryzacja Google nie powiodła się (anulowana).',
          code: 'google-reauth-cancelled',
        );
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
    } else {
      if (user.email == null) {
        throw FirebaseAuthException(
          message: 'Brak adresu email. Nie można zreautoryzować.',
          code: 'no-email',
        );
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword ?? '',
      );
      await user.reauthenticateWithCredential(credential);
    }
  }

  Future<void> _updateEmail() async {
    setState(() {
      _emailError = null;
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          message: 'Użytkownik nie jest zalogowany.',
          code: 'no-user',
        );
      }

      await _reauthenticateUser(
        currentPassword: _emailPasswordController.text.trim(),
      );

      await user.verifyBeforeUpdateEmail(_newEmailController.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Wysłano link weryfikacyjny na nowy adres email. Kliknij w link, aby potwierdzić zmianę.',
          ),
        ),
      );

      _newEmailController.clear();
      _emailPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _emailError = e.message;
      });
    } catch (e) {
      setState(() {
        _emailError = 'Wystąpił błąd przy aktualizacji emaila.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updatePassword() async {
    setState(() {
      _passwordError = null;
      _isLoading = true;
    });

    if (_newPasswordController.text.trim() !=
        _confirmNewPasswordController.text.trim()) {
      if (!mounted) return;
      setState(() {
        _passwordError = 'Nowe hasło i potwierdzenie nie są zgodne.';
        _isLoading = false;
      });
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          message: 'Użytkownik nie jest zalogowany.',
          code: 'no-user',
        );
      }

      await _reauthenticateUser(
        currentPassword: _currentPasswordForPasswordController.text.trim(),
      );

      await user.updatePassword(_newPasswordController.text.trim());
      await user.reload();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasło zostało pomyślnie zaktualizowane.'),
        ),
      );

      _currentPasswordForPasswordController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _passwordError = e.message;
      });
    } catch (e) {
      setState(() {
        _passwordError = 'Wystąpił błąd przy aktualizacji hasła.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _emailPasswordController.dispose();
    _currentPasswordForPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Prywatność i bezpieczeństwo'),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_loginProvider == 'google.com') ...[
                      const Text(
                        'Nie możesz zmienić hasła ani emaila, ponieważ jesteś zalogowany przez Google.',
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      Text(
                        'Aktualizacja emaila',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Podaj nowy email. Jeśli korzystasz z Email/Password, musisz wpisać także swoje obecne hasło. '
                        'Jeśli jesteś zalogowany przez Google, zostaniesz poproszony o ponowne zalogowanie w Google.',
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _newEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Nowy email',
                          hintText: 'Wprowadź nowy email',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Hasło (Email/Password)',
                          hintText: 'Wprowadź hasło, jeśli logujesz się mailem',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      if (_emailError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _emailError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _updateEmail,
                        style: ElevatedButton.styleFrom(),
                        child: const Text('Zmień email'),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        'Aktualizacja hasła',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jeśli jesteś zalogowany kontem Email/Password, podaj obecne hasło, a następnie wprowadź nowe hasło dwukrotnie. '
                        'Dla Google Sign-In zostaniesz poproszony o ponowne zalogowanie w Google.',
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _currentPasswordForPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Obecne hasło (Email/Password)',
                          hintText:
                              'Wprowadź obecne hasło (jeśli logujesz się mailem)',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Nowe hasło',
                          hintText: 'Wprowadź nowe hasło',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmNewPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Potwierdź nowe hasło',
                          hintText: 'Powtórz nowe hasło',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      if (_passwordError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _passwordError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _updatePassword,
                        child: const Text('Zmień hasło'),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
