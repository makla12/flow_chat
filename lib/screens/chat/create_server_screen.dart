import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateServerScreen extends StatefulWidget {
  const CreateServerScreen({super.key});

  @override
  CreateServerScreenState createState() => CreateServerScreenState();
}

class CreateServerScreenState extends State<CreateServerScreen> {
  void _createServer() {
    final serverName = _serverNameController.text;
    if (serverName.isEmpty) {
      return;
    }

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference serverRef = FirebaseFirestore.instance.collection('teams').doc();
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

  final _serverNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stwórz serwer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: <Widget>[
            TextField(
              controller: _serverNameController,
              decoration: InputDecoration(labelText: 'Nazwa serwera'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _createServer,
              child: Text('Stwórz serwer'),
            ),
          ],
        ),
      ),
    );
  }
}
