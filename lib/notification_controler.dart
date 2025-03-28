import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flow_chat/screens/chat/chanels_screen.dart';
import 'package:flow_chat/screens/chat/chat_screen.dart';
import 'package:flow_chat/screens/chat/notifications.dart';
import 'package:flow_chat/screens/chat/private_chat_screen.dart';
import 'package:flutter/material.dart';

class NotificationControler extends StatefulWidget {
  const NotificationControler({super.key, required, required this.child});
  final Widget child;

  @override
  State<NotificationControler> createState() => _NotificationControlerState();
}

class _NotificationControlerState extends State<NotificationControler> {
  StreamSubscription<RemoteMessage>? listener;
  @override
  void initState() {
    super.initState();
    var listener = FirebaseMessaging.onMessageOpenedApp.listen(( RemoteMessage message,) async {
      if(FirebaseAuth.instance.currentUser == null) return;
      var data = message.data;
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
      if(data['type'] == 'private_message') {
        DocumentReference privateChatRef = FirebaseFirestore.instance.collection("private_chats").doc(data['privateChatId']);
        Navigator.push(context, MaterialPageRoute(builder: (context) => PrivateChatScreen(privateChatRef: privateChatRef)));
      } 
      else if(data['type'] == 'server_message') {
        DocumentReference channelRef = FirebaseFirestore.instance.collection("servers").doc(data['serverId']).collection("channels").doc(data['chanelId']);
        DocumentSnapshot channelSnapshot = await channelRef.get();
        if(!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChannelsScreen(serverId: data['serverId'], ownerId: data['ownerId'])));
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(messagesRef: channelRef.collection("messages"), channelSnapshot: channelSnapshot)));
      } else if(data['type'] == 'invite') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsScreen()));
      } 
    });
    setState(() {
      this.listener = listener;
    });
  }

  @override
  void dispose() {
    super.dispose();
    listener?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
