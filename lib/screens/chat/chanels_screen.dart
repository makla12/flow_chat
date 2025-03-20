import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_chat/screens/chat/chat_screen.dart';
import 'package:flow_chat/screens/chat/invite_to_server_screen.dart';
import 'package:flow_chat/screens/chat/server_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({
    super.key,
    required this.serverId,
    required this.ownerId,
  });
  final String serverId;
  final String ownerId;

  @override
  _ChannelsScreenState createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  // Ustawienia wyglądu
  bool isLightMode = false;
  double fontSize = 14.0;
  Color accentColor = Colors.blue;

  // Referencja do kolekcji kanałów
  late final channelsRef = FirebaseFirestore.instance
      .collection('teams')
      .doc(widget.serverId)
      .collection('channels');
  late final Stream<QuerySnapshot> _channelsStream = channelsRef.snapshots();

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Wczytaj zapisane ustawienia wyglądu
  }

  // Ładowanie zapisanych ustawień
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

  @override
  Widget build(BuildContext context) {
    // Dynamiczne kolory zależne od ustawień
    Color backgroundColor =
        isLightMode ? Colors.white : const Color(0xFF0F172A);
    Color containerColor =
        isLightMode ? Colors.grey.shade200 : const Color(0xFF1F2937);
    Color textColor = isLightMode ? Colors.black : Colors.white;
    Color appBarColor = isLightMode ? Colors.blueGrey : const Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'Kanały',
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          InviteToServerScreen(serverId: widget.serverId),
                ),
              );
            },
          ),
          if (widget.ownerId == FirebaseAuth.instance.currentUser!.uid)
            IconButton(
              icon: Icon(Icons.add, color: textColor),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final TextEditingController controller =
                        TextEditingController();
                    return AlertDialog(
                      title: const Text('Dodaj kanał'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Nazwa kanału',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Anuluj'),
                        ),
                        TextButton(
                          onPressed: () {
                            final channelName = controller.text;
                            if (channelName.isNotEmpty) {
                              channelsRef.add({
                                'name': channelName,
                                'reed': [],
                              });
                            }
                            Navigator.pop(context);
                          },
                          child: const Text('Dodaj'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          if (widget.ownerId == FirebaseAuth.instance.currentUser!.uid)
            IconButton(
              icon: Icon(Icons.settings, color: textColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ServerSettingsScreen(serverId: widget.serverId),
                  ),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _channelsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Brak kanałów',
                style: TextStyle(color: textColor, fontSize: fontSize),
              ),
            );
          }

          final channels = snapshot.data!.docs;
          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              final bool isReed = channel['reed'].contains(
                FirebaseAuth.instance.currentUser!.uid,
              );
              return ListTile(
                title: Text(
                  channel['name'],
                  style: TextStyle(color: textColor, fontSize: fontSize),
                ),
                leading:
                    !isReed
                        ? const CircleAvatar(
                          backgroundColor: Colors.green,
                          maxRadius: 5,
                        )
                        : const SizedBox(),
                trailing:
                    widget.ownerId == FirebaseAuth.instance.currentUser!.uid
                        ? IconButton(
                          icon: Icon(Icons.delete, color: textColor),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Usuń kanał'),
                                  content: const Text(
                                    'Czy na pewno chcesz usunąć ten kanał?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Anuluj'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        channel.reference.delete();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Usuń'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        )
                        : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatScreen(
                            channelSnapshot: channel,
                            messagesRef: channel.reference.collection(
                              'messages',
                            ),
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
