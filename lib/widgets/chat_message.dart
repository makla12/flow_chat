import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage({super.key, required this.name, required this.time, required this.message});
  final String name;
  final String time;
  final String message;
  late final _friendStream = FirebaseFirestore.instance.collection('users').doc(name).snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(stream: _friendStream, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.data() == null) {
        return const Text("No messages");
      }
      final data = snapshot.data!.data()! as Map<String, dynamic>;
      final name = data['username'] as String;
      final avatarUrl = data['avatarUrl'] as String;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 5,
                  children: [Text(name, style: TextStyle(fontSize: 16)), Text(time, style: TextStyle(fontSize: 8))],
                ),
                Text(message, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      );
    });
  }
}
