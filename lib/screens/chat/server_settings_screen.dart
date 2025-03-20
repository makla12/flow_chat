import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerSettingsScreen extends StatefulWidget {
  const ServerSettingsScreen({super.key, required this.serverId});
  final String serverId;

  @override
  State<ServerSettingsScreen> createState() => _ServerSettingsScreenState();
}

class _ServerSettingsScreenState extends State<ServerSettingsScreen> {
  // Dynamiczne ustawienia wyglądu
  bool isLightMode = false;
  double fontSize = 14.0;
  Color accentColor = Colors.blue;

  // Gettery kolorów w zależności od trybu
  Color get backgroundColor =>
      isLightMode ? Colors.white : const Color(0xFF0F172A);
  Color get appBarColor =>
      isLightMode ? Colors.blueGrey : const Color(0xFF1E3A8A);
  Color get cardColor =>
      isLightMode ? Colors.grey.shade200 : const Color(0xFF1F2937);
  Color get textColor => isLightMode ? Colors.black : Colors.white;
  Color get iconColor => isLightMode ? Colors.black : Colors.white;

  late final serverRef = FirebaseFirestore.instance
      .collection('teams')
      .doc(widget.serverId);
  late final Stream<DocumentSnapshot> _serverStream = serverRef.snapshots();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Ładowanie ustawień wyglądu z SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLightMode = prefs.getBool('isLightMode') ?? false;
      fontSize = prefs.getDouble('fontSize') ?? 14.0;
      int savedColor = prefs.getInt('accentColor') ?? Colors.blue.value;
      accentColor = Color(savedColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'Ustawienia serwera',
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _serverStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(
              child: Text(
                'Brak danych',
                style: TextStyle(color: textColor, fontSize: fontSize),
              ),
            );
          }
          return Column(
            children: [
              ListTile(
                title: Text(
                  'Nazwa serwera',
                  style: TextStyle(color: textColor, fontSize: fontSize),
                ),
                subtitle: Text(
                  snapshot.data!['name'],
                  style: TextStyle(color: textColor, fontSize: fontSize),
                ),
                trailing: Icon(Icons.edit, color: iconColor),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final TextEditingController controller =
                          TextEditingController();
                      controller.text = snapshot.data!['name'];
                      return AlertDialog(
                        backgroundColor: cardColor,
                        title: Text(
                          'Zmień nazwę serwera',
                          style: TextStyle(
                            color: textColor,
                            fontSize: fontSize,
                          ),
                        ),
                        content: TextField(
                          controller: controller,
                          style: TextStyle(
                            color: textColor,
                            fontSize: fontSize,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nazwa serwera',
                            hintStyle: TextStyle(
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Anuluj',
                              style: TextStyle(
                                color: textColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              final serverName = controller.text;
                              if (serverName.isNotEmpty) {
                                serverRef.update({'name': serverName});
                                Navigator.pop(context);
                              }
                            },
                            child: Text(
                              'Zapisz',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: Text(
                  'Usuń serwer',
                  style: TextStyle(color: Colors.red, fontSize: fontSize),
                ),
                trailing: Icon(Icons.delete, color: Colors.red),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: cardColor,
                        title: Text(
                          'Usuń serwer',
                          style: TextStyle(
                            color: textColor,
                            fontSize: fontSize,
                          ),
                        ),
                        content: Text(
                          'Czy na pewno chcesz usunąć serwer?',
                          style: TextStyle(
                            color: textColor,
                            fontSize: fontSize,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Anuluj',
                              style: TextStyle(
                                color: textColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              serverRef.delete();
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );
                            },
                            child: Text(
                              'Usuń',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
