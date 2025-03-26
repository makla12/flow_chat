import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MembersScreen extends StatelessWidget {
  MembersScreen({super.key, required this.serverId, required this.ownerId});
  final String serverId;
  final String ownerId;

  late final _serverStream = FirebaseFirestore.instance.collection('servers').doc(serverId).snapshots();

  void _showRemoveMemberDialog(BuildContext context, member){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usuwanie członka'),
          content: const Text('Czy na pewno chcesz usunąć tego członka?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('servers').doc(serverId).update(
                  {
                    'members': FieldValue.arrayRemove([member])
                  }
                );
                Navigator.of(context).pop();
              },
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      child: StreamBuilder(stream: _serverStream, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Text("Brak użytkowników");
        }
        final serverData = snapshot.data!.data() as Map<String, dynamic>;

        return ListView.builder(
          itemCount: serverData['members'].length,
          itemBuilder: (context, index) {
            final memberStream = FirebaseFirestore.instance.collection('users').doc(serverData['members'][index]).snapshots();
            return StreamBuilder(stream: memberStream, builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Ładowanie...");
              }
              if(!snapshot.hasData || snapshot.data!.data() == null) {
                return const Text("Błąd ładowania użytkownika");
              }
              final userData = snapshot.data!.data() as Map<String, dynamic>;
                  return ListTile(
                    trailing:
                        (serverData['ownerId'] ==
                                    FirebaseAuth.instance.currentUser!.uid &&
                                serverData['members'][index] !=
                                    FirebaseAuth.instance.currentUser!.uid)
                            ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showRemoveMemberDialog(context, serverData['members'][index]),
                            )
                            : null,
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple,
                      backgroundImage:
                          userData['avatarUrl'] != null &&
                                  userData['avatarUrl'].isNotEmpty
                              ? NetworkImage(userData['avatarUrl'])
                              : null,
                      child:
                          userData['avatarUrl'] == null ||
                                  userData['avatarUrl'].isEmpty
                              ? const Icon(Icons.person)
                              : null,
                    ),
                    title: Text(userData['username']),
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
