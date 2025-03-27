import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flow_chat/widgets/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.messagesRef, required this.channelSnapshot});

  final QueryDocumentSnapshot channelSnapshot;
  final CollectionReference messagesRef;

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController textController = TextEditingController();
  late final Stream<QuerySnapshot> _messagesStream = widget.messagesRef.orderBy("time").snapshots();

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
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(widget.channelSnapshot.reference, {
        'reed': [],
      });
      transaction.set(widget.messagesRef.doc(), messageData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelSnapshot['name']),
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
                child: StreamBuilder<QuerySnapshot>(stream: _messagesStream, builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  widget.channelSnapshot.reference.update({
                    'reed': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
                  });

                  if(!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Brak wiadomości'));
                  }
                  final messages = snapshot.data!.docs;

                  return ListView.separated(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageIndex = messages.length - 1 - index;
                      final message = messages[messageIndex];
                      final isCompact = messageIndex == 0 ? false : messages[messageIndex - 1]['name'] == message['name'] && message['time'].toDate().difference(messages[messageIndex - 1]['time'].toDate()).inMinutes < 2;
                      return ChatMessage(
                        name: message['name'],
                        time: message['time'],
                        message: message['message'],
                        compact: isCompact,
                      );
                    },
                    separatorBuilder:
                        (context, index) {
                          final messageIndex = messages.length - 1 - index;
                          final isCompact = messageIndex == 0 ? false : messages[messageIndex - 1]['name'] == messages[messageIndex]['name'] && messages[messageIndex]['time'].toDate().difference(messages[messageIndex - 1]['time'].toDate()).inMinutes < 2;
                          return isCompact ? const SizedBox(height: 0) : const SizedBox(height: 10); 
                        },
                  );
                }),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 150,
                      ),
                      child: SizedBox(
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
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                        
                            hintText: "Wiadomość",
                          ),
                        ),
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
