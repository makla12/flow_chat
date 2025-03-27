import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_chat/utils/time_utils.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage({super.key, required this.name, required this.time, required this.message, this.compact = false});
  final String name;
  final Timestamp time;
  final String message;
  final bool compact;
  late final _friendStream = FirebaseFirestore.instance.collection('users').doc(name).snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(stream: _friendStream, builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.data() == null) {
        return const SizedBox();
      }
      final data = snapshot.data!.data()! as Map<String, dynamic>;
      final name = data['username'] as String;
      final avatarUrl = data['avatarUrl'] as String;
      final bool self = FirebaseAuth.instance.currentUser!.uid == this.name;
      return compact ? Padding(padding: EdgeInsets.only(left: self ? 0 : 50, right: self ? 50 : 0), child: Text(message, textAlign: self ? TextAlign.right : TextAlign.left,),) : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          !self ? CircleAvatar(backgroundImage: NetworkImage(avatarUrl)) : const SizedBox(),
          Expanded(
            child: Column(
              crossAxisAlignment: self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: self ? MainAxisAlignment.end : MainAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Text(name, style: TextStyle(fontSize: 16)),
                    Text(TimeUtils.convertTime(time), style: TextStyle(fontSize: 8)),
                  ],
                ),
                Text(message, textAlign: self ? TextAlign.right : TextAlign.left, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          self ? CircleAvatar(backgroundImage: NetworkImage(avatarUrl)) : const SizedBox(),
        ],
      );
    });
  }
}
