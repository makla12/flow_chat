import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_chat/screens/chat/chat_screen.dart';
import 'package:flow_chat/screens/chat/server_settings_screen.dart';
import 'package:flutter/material.dart';

class ChannelsScreen extends StatelessWidget {
  ChannelsScreen({super.key, required this.serverId, required this.ownerId});
  final String serverId;
  final String ownerId;

  late final channelsRef = FirebaseFirestore.instance
      .collection('teams')
      .doc(serverId)
      .collection('channels');
  late final Stream<QuerySnapshot> _channelsStream = channelsRef.snapshots();

  final Color backgroundColor = Color(0xFF0F172A);
  final Color appBarColor = Color(0xFF1E3A8A);
  final Color containerColor = Color(0xFF1F2937);
  final Color dividerColor = Color(0xFF2F3A4B);
  final Color buttonColor = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text('Kanały'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.person_add_alt)),
          if (ownerId == FirebaseAuth.instance.currentUser!.uid)
            IconButton(
              icon: Icon(Icons.add),
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
                                'messages': [],
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
          if(ownerId == FirebaseAuth.instance.currentUser!.uid)
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ServerSettingsScreen(serverId: serverId)));
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
            return const Center(child: Text('Brak kanałów'));
          }

          final channels = snapshot.data!.docs;

          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return ListTile(
                title: Text(channel['name']),
                trailing:
                    ownerId == FirebaseAuth.instance.currentUser!.uid
                        ? IconButton(
                          icon: Icon(Icons.delete),
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
                            channelName: channel['name'],
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
