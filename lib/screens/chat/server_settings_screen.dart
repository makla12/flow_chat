
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServerSettingsScreen extends StatelessWidget {
  ServerSettingsScreen({super.key, required this.serverId });

  final String serverId;

  late final serverRef = FirebaseFirestore.instance
      .collection('teams')
      .doc(serverId);
  late final Stream<DocumentSnapshot> _serverStream = serverRef.snapshots();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E3A8A),
        title: Text('Ustawienia serwera'),
      ),
      body: StreamBuilder<DocumentSnapshot>(stream: _serverStream, builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(),);
        }
        if(!snapshot.hasData || snapshot.data!.data() == null) {
          return Center(child: Text('Brak danych'),);
        }
        return Column(
          children: [
            ListTile(
              title: Text('Nazwa serwera'),
              subtitle: Text(snapshot.data!['name']),
              trailing: Icon(Icons.edit),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final TextEditingController controller = TextEditingController();
                    controller.text = snapshot.data!['name'];
                    return AlertDialog(
                      title: const Text('Zmień nazwę serwera'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Nazwa serwera',
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
              },
            ),
            ListTile(
              title: Text('Usuń serwer', style: TextStyle(color: Colors.red),),
              trailing: Icon(Icons.delete, color: Colors.red),
              onTap: () {
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
                            Navigator.popUntil(context, ModalRoute.withName('/'));
                          },
                          child: const Text('Usuń'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },)
    );
  }

}