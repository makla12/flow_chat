import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
            return const Center(
              child: Text(
                "Brak powiadomień",
                style: TextStyle(color: Colors.white, fontSize: 18),
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

                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Icon(
                        invite["type"] == "server" ? Icons.group : Icons.person,
                        color: Colors.white,
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
                                    return const Text(
                                      "Ładowanie...",
                                      style: TextStyle(color: Colors.white),
                                    );
                                  }
                                  if (!snapshot.hasData || snapshot.data!.data() == null) {
                                    onDeclineInvite(invite.id);
                                    return const Text(
                                      "Błąd zaproszenia",
                                      style: TextStyle(color: Colors.white),
                                    );
                                  }
                                  final serverData =
                                      snapshot.data!.data()
                                          as Map<String, dynamic>;
                                  return Text(
                                    "Zaproszenie do serwera ${serverData["name"]}",
                                    style: const TextStyle(color: Colors.white),
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
                                      style: TextStyle(color: Colors.white),
                                    );
                                  }
                                  if(!snapshot.hasData || snapshot.data!.data() == null) {
                                    onDeclineInvite(invite.id);
                                    return const Text(
                                      "Użytkownik nie istnieje",
                                      style: TextStyle(color: Colors.white),
                                    );
                                  }
                                  
                                  final userData =
                                      snapshot.data!.data()
                                          as Map<String, dynamic>;
                                  return Text(
                                    "Zaproszenie do znajomych od ${userData["username"]}",
                                    style: const TextStyle(color: Colors.white),
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
                                color: Colors.white,
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
