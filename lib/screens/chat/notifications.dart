import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;

  void onAcceptInvite(String inviteId) async {
    setState(() {
      _isLoading = true;
    });
    final invite =
        await FirebaseFirestore.instance
            .collection('invites')
            .doc(inviteId)
            .get();
    if (invite['type'] == 'server') {
      final serverData =
          await FirebaseFirestore.instance
              .collection('servers')
              .doc(invite['from'])
              .get();
      final server = serverData.data() as Map<String, dynamic>;
      final members = List<String>.from(server['members']);
      members.add(FirebaseAuth.instance.currentUser!.uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(
          FirebaseFirestore.instance.collection('servers').doc(invite['from']),
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
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        List<String> privateChatIds = [userData.id, userData2.id];
        transaction.set(
          FirebaseFirestore.instance.collection('private_chats').doc(),
          {
            'members': privateChatIds,
            'reed': [],
            'muted': [],
            'lastMessage': {
              'name': '',
              'message': '',
              'time': DateTime.now(),
            },
          },
        );

        transaction.delete(
          FirebaseFirestore.instance.collection('invites').doc(inviteId),
        );
      });
    }
    setState(() {
      _isLoading = false;
    });
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
      appBar: AppBar(
        title: const Text(
          'Powiadomienia',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: invitesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Brak powiadomień",
                style: TextStyle(fontSize: 18),
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),

                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Icon(
                        invite["type"] == "server" ? Icons.group : Icons.person,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child:
                          invite["type"] == "server"
                              ? StreamBuilder<DocumentSnapshot>(
                                stream:
                                    FirebaseFirestore.instance
                                        .collection('servers')
                                        .doc(invite["from"])
                                        .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text(
                                      "Ładowanie...",
                                    );
                                  }
                                  if (!snapshot.hasData || snapshot.data!.data() == null) {
                                    onDeclineInvite(invite.id);
                                    return const Text(
                                      "Błąd zaproszenia",
                                    );
                                  }
                                  final serverData =
                                      snapshot.data!.data()
                                          as Map<String, dynamic>;
                                  return Text(
                                    "Zaproszenie do serwera ${serverData["name"]}",
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
                                    return const Text(
                                      "Ładowanie...",
                                    );
                                  }
                                  if(!snapshot.hasData || snapshot.data!.data() == null) {
                                    onDeclineInvite(invite.id);
                                    return const Text(
                                      "Użytkownik nie istnieje",
                                    );
                                  }
                                  
                                  final userData =
                                      snapshot.data!.data()
                                          as Map<String, dynamic>;
                                  return Text(
                                    "Zaproszenie do znajomych od ${userData["username"]}",
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
                              backgroundColor: Colors.green,
                              minimumSize: const Size(70, 30),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            child: const Text(
                              "✓",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton(
                            onPressed: () => onDeclineInvite(invite.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(70, 30),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            child: const Text(
                              "✕",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
