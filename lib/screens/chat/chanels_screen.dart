import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_chat/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';

class ChannelsScreen extends StatelessWidget {
  ChannelsScreen({super.key, required this.serverId});
  final String serverId;

  late final serverRef = FirebaseFirestore.instance
      .collection('teams')
      .doc(serverId);
  late final Stream<DocumentSnapshot> _channelsStream = serverRef.snapshots();

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
        title: Text('Channels'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.person_add_alt)),
          StreamBuilder(
            stream: _channelsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.data() == null) {
                return const Text('');
              }
              final data = snapshot.data!.data() as Map<String, dynamic>;
              if (data['ownerId'] != FirebaseAuth.instance.currentUser!.uid) {
                return const Text('');
              }

              return IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final TextEditingController controller =
                          TextEditingController();
                      return AlertDialog(
                        title: const Text('Add Channel'),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'Channel Name',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              final channelName = controller.text;
                              if (channelName.isNotEmpty) {
                                serverRef.update({
                                  'channels': FieldValue.arrayUnion([
                                    {'messages': [], 'name': channelName},
                                  ]),
                                });
                              }
                              Navigator.pop(context);
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _channelsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text('Sever does not exist'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final channels = data['channels'] as List<dynamic>;
          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index] as Map<String, dynamic>;
              return ListTile(
                title: Text(channel['name']),
                trailing:
                    data['ownerId'] == FirebaseAuth.instance.currentUser!.uid
                        ? IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Channel'),
                                  content: const Text(
                                    'Are you sure you want to delete this channel?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        serverRef.update({
                                          'channels': FieldValue.arrayRemove([
                                            channel,
                                          ]),
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Delete'),
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
                            serverId: serverId,
                            chanelIndex: index,
                            chanelName: channel['name'],
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
