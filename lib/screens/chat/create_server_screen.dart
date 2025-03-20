import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateServerScreen extends StatefulWidget {
  const CreateServerScreen({super.key});

  @override
  CreateServerScreenState createState() => CreateServerScreenState();
}

class CreateServerScreenState extends State<CreateServerScreen> {
  // Ustawienia wyglądu
  bool isLightMode = false;
  double fontSize = 14.0;
  Color accentColor = Colors.blue;

  // Dynamiczne kolory zależne od preferencji
  Color get backgroundColor =>
      isLightMode ? Colors.white : const Color(0xFF0F172A);
  Color get appBarColor =>
      isLightMode ? Colors.blueGrey : const Color(0xFF1E3A8A);
  Color get containerColor =>
      isLightMode ? Colors.grey.shade200 : const Color(0xFF1F2937);
  Color get dividerColor => isLightMode ? Colors.grey : const Color(0xFF2F3A4B);
  Color get buttonColor => accentColor;
  Color get textColor => isLightMode ? Colors.black : Colors.white;

  final _serverNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Ładowanie zapisanych ustawień wyglądu
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLightMode = prefs.getBool('isLightMode') ?? false;
      fontSize = prefs.getDouble('fontSize') ?? 14.0;
      int savedColor = prefs.getInt('accentColor') ?? Colors.blue.value;
      accentColor = Color(savedColor);
    });
  }

  // Zapis trybu jasnego
  Future<void> _saveLightMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLightMode', value);
  }

  // Zapis rozmiaru czcionki
  Future<void> _saveFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSize', value);
  }

  // Zapis koloru akcentu
  Future<void> _saveAccentColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('accentColor', color.value);
  }

  // Przełączanie trybu jasnego
  void toggleLightMode() {
    setState(() {
      isLightMode = !isLightMode;
    });
    _saveLightMode(isLightMode);
  }

  void _createServer() {
    final serverName = _serverNameController.text;
    if (serverName.isEmpty) {
      return;
    }

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference serverRef =
          FirebaseFirestore.instance.collection('teams').doc();
      transaction.set(serverRef, {
        'name': serverName,
        'members': [FirebaseAuth.instance.currentUser!.uid],
        'muted': [],
        'ownerId': FirebaseAuth.instance.currentUser!.uid,
      });

      DocumentReference channelRef = serverRef.collection('channels').doc();
      transaction.set(channelRef, {
        'name': 'general',
        'muted': [],
        'reed': [],
      });
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'Stwórz serwer',
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
        actions: [
          // Przycisk do przełączania trybu jasnego
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _serverNameController,
              style: TextStyle(color: textColor, fontSize: fontSize),
              decoration: InputDecoration(
                labelText: 'Nazwa serwera',
                labelStyle: TextStyle(color: textColor),
                filled: true,
                fillColor: containerColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _createServer,
              child: Text(
                'Stwórz serwer',
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
