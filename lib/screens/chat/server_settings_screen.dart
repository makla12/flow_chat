
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServerSettingsScreen extends StatelessWidget {
  ServerSettingsScreen({super.key, required this.serverId, required this.ownerId});
  final String serverId;
  final String ownerId;

  late final serverRef = FirebaseFirestore.instance
      .collection('teams')
      .doc(serverId);
  late final Stream<DocumentSnapshot> _serverStream = serverRef.snapshots();


  void _showServerNameChangeDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Zmień nazwę serwera'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nazwa serwera'),
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
                final serverName = controller.text;
                if (serverName.isNotEmpty) {
                  serverRef.update({'name': serverName});
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

  void _showServerDeleteDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usuń serwer'),
          content: const Text('Czy na pewno chcesz usunąć serwer?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () {
                serverRef.delete();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );
  }

  void _showServerLeaveDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Opuść serwer'),
          content: const Text('Czy na pewno chcesz opuścić serwer?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () {
                serverRef.update({
                  'members': FieldValue.arrayRemove([
                    FirebaseAuth.instance.currentUser!.uid,
                  ]),
                });
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Opuść'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ustawienia serwera'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _serverStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('Brak danych'));
          }
          return Column(
            children: [
              (snapshot.data!['muted'] as List<dynamic>).contains(
                    FirebaseAuth.instance.currentUser!.uid,
                  )
                  ? ListTile(
                    title: Text('Wyłącz wyciszenie servera'),
                    trailing: Icon(Icons.notifications_on),
                    onTap: () {
                      serverRef.update({
                        'muted': FieldValue.arrayRemove([
                          FirebaseAuth.instance.currentUser!.uid,
                        ]),
                      });
                    },
                  )
                  : ListTile(
                    title: Text('Wycisz serwer'),
                    trailing: Icon(Icons.notifications_off),
                    onTap: () {
                      serverRef.update({
                        'muted': FieldValue.arrayUnion([
                          FirebaseAuth.instance.currentUser!.uid,
                        ]),
                      });
                    },
                  ),
              if (ownerId == FirebaseAuth.instance.currentUser!.uid)
                ListTile(
                  title: Text('Nazwa serwera'),
                  subtitle: Text(snapshot.data!['name']),
                  trailing: Icon(Icons.edit),
                  onTap: () => _showServerNameChangeDialog(context),
                ),
              (ownerId == FirebaseAuth.instance.currentUser!.uid)
                  ? ListTile(
                    title: Text(
                      'Usuń serwer',
                      style: TextStyle(color: Colors.red),
                    ),
                    trailing: Icon(Icons.delete, color: Colors.red),
                    onTap: () => _showServerDeleteDialog(context),
                  )
                  : ListTile(
                    title: Text(
                      'Opuść serwer',
                      style: TextStyle(color: Colors.red),
                    ),
                    trailing: Icon(Icons.exit_to_app, color: Colors.red),
                    onTap: () => _showServerLeaveDialog(context),
                  ),
            ],
          );
        },
      ),
    );
  }

}