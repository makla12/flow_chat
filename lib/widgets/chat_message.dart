import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget {
  ChatMessage({super.key, required this.userId, required this.time, required this.message});
  final String userId;
  final Timestamp time;
  final String message;

  @override
  ChatMessageState createState() => ChatMessageState();
}

class ChatMessageState extends State<ChatMessage> {
  String? name;
  String? avatarUrl;
  late final _friendRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
  void getFriendData() {
    _friendRef.get().then((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          name = data['username'] as String;
          avatarUrl = data['avatarUrl'] as String;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getFriendData();
  }

  @override
  Widget build(BuildContext context) {
    return (name == null || avatarUrl == null ? Text("") : Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(backgroundImage: NetworkImage(avatarUrl!)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [Text(name!, style: TextStyle(fontSize: 16)), Text(widget.time.toDate().toIso8601String(), style: TextStyle(fontSize: 8))],
              ),
              Text(widget.message, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    ));
  }
}
