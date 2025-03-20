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

  void _showChanelAddDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Dodaj kanał'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nazwa kanału'),
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
                    'muted': [],
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
  }

  void _showDeleteChannelDialog(context, QueryDocumentSnapshot channel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usuń kanał'),
          content: const Text('Czy na pewno chcesz usunąć ten kanał?'),
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
                Navigator.pop(context);
              },
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );
  }

  void _showChannelNameEditDialog(context, QueryDocumentSnapshot channel) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Zmień nazwę kanału'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nazwa kanału'),
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
                  channel.reference.update({'name': channelName});
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }

  void _openChanelMenu(context, QueryDocumentSnapshot channel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (channel['muted'].contains(FirebaseAuth.instance.currentUser!.uid))
                ? ListTile(
                  title: Text('Włącz powiadomienia'),
                  trailing: Icon(Icons.notifications),
                  onTap: () {
                    channel.reference.update({
                      'muted': FieldValue.arrayRemove([
                        FirebaseAuth.instance.currentUser!.uid,
                      ]),
                    });
                    Navigator.pop(context);
                  },
                )
                : ListTile(
                  title: Text('Wyłącz powiadomienia'),
                  trailing: Icon(Icons.notifications_off),
                  onTap: () {
                    channel.reference.update({
                      'muted': FieldValue.arrayUnion([
                        FirebaseAuth.instance.currentUser!.uid,
                      ]),
                    });
                    Navigator.pop(context);
                  },
                ),
            (channel['reed'].contains(FirebaseAuth.instance.currentUser!.uid))
                ? ListTile(
                  title: Text('Oznacz jako nieprzeczytane'),
                  trailing: Icon(Icons.close),
                  onTap: () {
                    channel.reference.update({
                      'reed': FieldValue.arrayRemove([
                        FirebaseAuth.instance.currentUser!.uid,
                      ]),
                    });
                    Navigator.pop(context);
                  },
                )
                : ListTile(
                  title: Text('Oznacz jako przeczytane'),
                  trailing: Icon(Icons.check),
                  onTap: () {
                    channel.reference.update({
                      'reed': FieldValue.arrayUnion([
                        FirebaseAuth.instance.currentUser!.uid,
                      ]),
                    });
                    Navigator.pop(context);
                  },
                ),
            if (widget.ownerId == FirebaseAuth.instance.currentUser!.uid)
              ListTile(
                title: Text('Zmień nazwę kanału'),
                trailing: Icon(Icons.edit),
                onTap: () => _showChannelNameEditDialog(context, channel),
              ),
            if (widget.ownerId == FirebaseAuth.instance.currentUser!.uid)
              ListTile(
                title: Text('Usuń kanał', style: TextStyle(color: Colors.red)),
                trailing: Icon(Icons.delete, color: Colors.red),
                onTap: () => _showDeleteChannelDialog(context, channel),
              ),
          ],
        );
      },
    );
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => InviteToServerScreen(serverId: widget.serverId),
                ),
              );
            },
            icon: Icon(Icons.person_add_alt),
          ),
          if (widget.ownerId == FirebaseAuth.instance.currentUser!.uid)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showChanelAddDialog(context),
            ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ServerSettingsScreen(
                        serverId: widget.serverId,
                        ownerId: widget.ownerId,
                      ),
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
                title: Text(channel['name']),
                trailing: (channel['muted'].contains(FirebaseAuth.instance.currentUser!.uid,)) ? const Icon(Icons.notifications_off) : null,
                leading:
                    !isReed
                        ? const CircleAvatar(
                          backgroundColor: Colors.green,
                          maxRadius: 5,
                        )
                        : const SizedBox(),
                onLongPress: () => _openChanelMenu(context, channel),
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
