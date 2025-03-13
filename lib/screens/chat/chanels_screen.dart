import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow_chat/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';

class ChannelsScreen extends StatelessWidget {
  ChannelsScreen({super.key ,required this.serverId});
  final String serverId;

  late final Stream<DocumentSnapshot> _channelsStream = FirebaseFirestore.instance
      .collection('teams')
      .doc(serverId)
      .snapshots();

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
      ),
      body: StreamBuilder<DocumentSnapshot>(stream: _channelsStream, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No channels'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        print(data["channels"]);
        final channels = data['channels'] as List<dynamic>;
        return ListView.builder(
          itemCount: channels.length,
          itemBuilder: (context, index) {
            final channel = channels[index] as Map<String, dynamic>;
            print(channel);
            return ListTile(
              title: Text(channel['name']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
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
      }),
    );
  }
}