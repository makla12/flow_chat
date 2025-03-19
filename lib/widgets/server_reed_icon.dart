import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServerReedIcon extends StatelessWidget {
  ServerReedIcon({super.key, required this.serverSnapshot});
  final QueryDocumentSnapshot serverSnapshot;

  late final Stream<QuerySnapshot> _chanelsStream = serverSnapshot.reference.collection('channels').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: _chanelsStream, builder: (context, snapshot){
      if(snapshot.connectionState == ConnectionState.waiting) return SizedBox();
      if(!snapshot.hasData) return SizedBox();
      final channels = snapshot.data!.docs;
      final reed = channels.where((channel) => channel['reed'].contains(FirebaseAuth.instance.currentUser!.uid)).toList();
      if(channels.length == reed.length) return SizedBox();

      return CircleAvatar(
        backgroundColor: Colors.green,
        maxRadius: 5,
      );
    });
  }
}