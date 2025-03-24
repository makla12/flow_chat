import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pamiętaj o dodaniu google_sign_in do pubspec.yaml

class PrivacyAndSecurityScreen extends StatefulWidget {
  const PrivacyAndSecurityScreen({super.key});

  @override
  PrivacyAndSecurityScreenState createState() =>
      PrivacyAndSecurityScreenState();
}

class PrivacyAndSecurityScreenState extends State<PrivacyAndSecurityScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // -- Pola do zmiany emaila (dla użytkowników Email/Password)
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _emailPasswordController =
      TextEditingController();

  // -- Pola do zmiany hasła (dla użytkowników Email/Password)
  final TextEditingController _currentPasswordForPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String?
  _loginProvider; // Zmienna do przechowywania informacji o dostawcy logowania
  bool isLightMode = false;

  @override
  void initState() {
    super.initState();
    _checkLoginProvider(); // Sprawdzamy, jakim dostawcą jest użytkownik
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLightMode = prefs.getBool('isLightMode') ?? false;
    });
  }

  /// Funkcja sprawdzająca, jakim dostawcą (provider) jest zalogowany użytkownik.
  Future<void> _checkLoginProvider() async {
    final user = _auth.currentUser;
    if (user != null && user.providerData.isNotEmpty) {
      setState(() {
        _loginProvider =
            user.providerData.first.providerId; // 'google.com' lub 'password'
      });
    }
  }

  /// Funkcja sprawdzająca, jakim dostawcą (provider) jest zalogowany użytkownik,
  /// a następnie przeprowadzająca reautoryzację.
  ///
  /// - Dla Email/Password prosimy o hasło.
  /// - Dla Google Sign-In wywołujemy ponowne GoogleSignIn().
  Future<void> _reauthenticateUser({String? currentPassword}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        message: 'Użytkownik nie jest zalogowany.',
        code: 'no-user',
      );
    }

    // Sprawdzamy, jakim dostawcą jest zalogowany użytkownik.
    final providerId =
        user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'password'; // jeśli pusto, zakładamy password

    if (providerId == 'google.com') {
      // Reautoryzacja z Google
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Użytkownik anulował logowanie w oknie Google
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
      // Email/Password
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

  /// Zmiana emaila (bez verifyBeforeUpdateEmail)
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

      // Reautoryzacja (dla Email/Password - hasło z _emailPasswordController, dla Google - GoogleSignIn)
      await _reauthenticateUser(
        currentPassword: _emailPasswordController.text.trim(),
      );

      // Wysyłanie maila weryfikacyjnego i aktualizacja emaila po potwierdzeniu
      await user.verifyBeforeUpdateEmail(_newEmailController.text.trim());

      // Ważne! Nowy email nie jest od razu zapisany, więc użytkownik musi potwierdzić go w skrzynce pocztowej.
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Wysłano link weryfikacyjny na nowy adres email. Kliknij w link, aby potwierdzić zmianę.',
          ),
        ),
      );

      // Opróżnienie pól po sukcesie
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Zmiana hasła
  Future<void> _updatePassword() async {
    setState(() {
      _passwordError = null;
      _isLoading = true;
    });

    // Walidacja, czy nowe hasło i potwierdzenie są zgodne
    if (_newPasswordController.text.trim() !=
        _confirmNewPasswordController.text.trim()) {
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

      // Reautoryzacja
      await _reauthenticateUser(
        currentPassword: _currentPasswordForPasswordController.text.trim(),
      );

      // Aktualizacja hasła
      await user.updatePassword(_newPasswordController.text.trim());
      await user.reload();

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasło zostało pomyślnie zaktualizowane.'),
        ),
      );

      // Czyścimy pola po sukcesie
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
      setState(() {
        _isLoading = false;
      });
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
        title: const Text(
          'Prywatność i bezpieczeństwo',
        ),
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
                      // Informacja, że nie można zmieniać emaila i hasła, jeśli użytkownik jest zalogowany przez Google
                      const Text(
                        'Nie możesz zmienić hasła ani emaila, ponieważ jesteś zalogowany przez Google.',
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      // =========================
                      // SEKCJA AKTUALIZACJI EMAILA
                      // =========================
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
                        style: ElevatedButton.styleFrom(
                        ),
                        child: const Text('Zmień email'),
                      ),
                      const SizedBox(height: 32),

                      // =========================
                      // SEKCJA AKTUALIZACJI HASŁA
                      // =========================
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
