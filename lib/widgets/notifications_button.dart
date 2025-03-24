import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow_chat/screens/chat/notifications.dart';
import 'package:flutter/material.dart';

class NotificationsButton extends StatelessWidget {
  NotificationsButton({super.key, required this.userId});
  final String userId;
  late final Stream<QuerySnapshot> _notificationsStream =
      FirebaseFirestore.instance
          .collection('invites')
          .where('to', isEqualTo: userId)
          .snapshots();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        children: [
          Icon(Icons.notifications),
          StreamBuilder(
            stream: _notificationsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox();
              }
              return Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    snapshot.data!.docs.length.toString(),
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationsScreen()),
        );
      },
    );
  }
}
