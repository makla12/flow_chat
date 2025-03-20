import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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

  void onAcceptInvite(String inviteId) async {
    final invite =
        await FirebaseFirestore.instance
            .collection('invites')
            .doc(inviteId)
            .get();
    if (invite['type'] == 'server') {
      final serverData =
          await FirebaseFirestore.instance
              .collection('teams')
              .doc(invite['from'])
              .get();
      final server = serverData.data() as Map<String, dynamic>;
      final members = List<String>.from(server['members']);
      members.add(FirebaseAuth.instance.currentUser!.uid);
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(
          FirebaseFirestore.instance.collection('teams').doc(invite['from']),
          {'members': members},
        );
        transaction.delete(
          FirebaseFirestore.instance.collection('invites').doc(inviteId),
        );
      });
    } else {
      final userData =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(invite['from'])
              .get();
      final userData2 =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();
      FirebaseFirestore.instance.runTransaction((transaction) async {
        List<String> privateChatIds = [userData.id, userData2.id];
        transaction.set(
          FirebaseFirestore.instance.collection('private_chats').doc(),
          {
            'members': privateChatIds,
            'reed': [],
            'lastMessage': {'name': '', 'message': '', 'time': DateTime.now()},
          },
        );
        transaction.delete(
          FirebaseFirestore.instance.collection('invites').doc(inviteId),
        );
      });
    }
  }

  void onDeclineInvite(String inviteId) async {
    try {
      FirebaseFirestore.instance.collection('invites').doc(inviteId).delete();
    } catch (e) {
      print('Błąd usuwania zaproszenia: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final invitesStream =
        FirebaseFirestore.instance
            .collection('invites')
            .where('to', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'Powiadomienia',
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: invitesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Brak powiadomień",
                style: TextStyle(color: textColor, fontSize: fontSize + 4),
              ),
            );
          }
          final invites = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.only(top: 10),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: invites.length,
            itemBuilder: (context, index) {
              final invite = invites[index];
              return Material(
                borderRadius: BorderRadius.circular(20),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Icon(
                          invite["type"] == "server"
                              ? Icons.group
                              : Icons.person,
                          color: iconColor,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child:
                            invite["type"] == "server"
                                ? StreamBuilder<DocumentSnapshot>(
                                  stream:
                                      FirebaseFirestore.instance
                                          .collection('teams')
                                          .doc(invite["from"])
                                          .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                        "Ładowanie...",
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: fontSize,
                                        ),
                                      );
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data!.data() == null) {
                                      onDeclineInvite(invite.id);
                                      return Text(
                                        "Błąd zaproszenia",
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: fontSize,
                                        ),
                                      );
                                    }
                                    final serverData =
                                        snapshot.data!.data()
                                            as Map<String, dynamic>;
                                    return Text(
                                      "Zaproszenie do serwera ${serverData["name"]}",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: fontSize,
                                      ),
                                    );
                                  },
                                )
                                : StreamBuilder<DocumentSnapshot>(
                                  stream:
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(invite["from"])
                                          .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                        "Ładowanie...",
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: fontSize,
                                        ),
                                      );
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data!.data() == null) {
                                      onDeclineInvite(invite.id);
                                      return Text(
                                        "Użytkownik nie istnieje",
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: fontSize,
                                        ),
                                      );
                                    }
                                    final userData =
                                        snapshot.data!.data()
                                            as Map<String, dynamic>;
                                    return Text(
                                      "Zaproszenie do znajomych od ${userData["username"]}",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: fontSize,
                                      ),
                                    );
                                  },
                                ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => onAcceptInvite(invite.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                minimumSize: const Size(70, 30),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              child: Text(
                                "✓",
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            ElevatedButton(
                              onPressed: () => onDeclineInvite(invite.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size(70, 30),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              child: Text(
                                "✕",
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
