
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flow_chat/widgets/chat_message.dart';

class PrivateChatScreen extends StatefulWidget {
  const PrivateChatScreen({super.key, required this.privateChatId});

  final String privateChatId;

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<PrivateChatScreen> {
  final TextEditingController textController = TextEditingController();
  late final CollectionReference _messagesRef = FirebaseFirestore.instance
      .collection('private_chats')
      .doc(widget.privateChatId)
      .collection('messages');

  late final Stream<QuerySnapshot> _messagesStream = _messagesRef.orderBy("time").snapshots();

  void _sendMessage() async {
    final message = textController.text;
    textController.clear();
    if (message.isEmpty) {
      return;
    }

    final messageData = {
      'name': FirebaseAuth.instance.currentUser!.uid,
      'time': DateTime.now(),
      'message': message,
    };
    _messagesRef.doc().set(messageData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E3A8A),
        title: Text('Chat', style: TextStyle(color: Colors.white)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xff2d3748))),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _messagesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('Brak wiadomości'));
                    }
                    final messages = snapshot.data!.docs;

                    return ListView.separated(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[messages.length - 1 - index];
                        return ChatMessage(
                          userId: message['name'],
                          time: message['time'],
                          message: message['message'],
                        );
                      },
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 10),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          bottom: 5,
                          top: 5,
                        ),
                        filled: true,
                        fillColor: Color(0xff36343b),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),

                        hintText: "Wiadomość",
                      ),
                    ),
                  ),
                  IconButton(onPressed: _sendMessage, icon: Icon(Icons.send)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
