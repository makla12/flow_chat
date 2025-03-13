import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flow_chat/widgets/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.serverId, required this.chanelIndex, required this.chanelName});

  final String serverId;
  final int chanelIndex;
  final String chanelName;

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController textController = TextEditingController();
  late final Stream<DocumentSnapshot> _messagesStream = FirebaseFirestore.instance
      .collection('teams')
      .doc(widget.serverId)
      .snapshots();

  void _sendMessage() async {
    final message = textController.text;
    textController.clear();
    if (message.isEmpty) {
      return;
    }

    final messageData = {
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'time': DateTime.now().toIso8601String(),
      'message': message,
    };
    final docRef = FirebaseFirestore.instance.collection('teams').doc(widget.serverId);

    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      final channels = data['channels'] as List<dynamic>;

      channels[widget.chanelIndex]['messages'].add(messageData);

      await docRef.update({'channels': channels});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E3A8A),
        title: Text(widget.chanelName, style: TextStyle(color: Colors.white)),
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
                child: StreamBuilder<DocumentSnapshot>(stream: _messagesStream, builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final channels = data['channels'] as List<dynamic>;
                  final messages = channels[widget.chanelIndex]['messages'] as List<dynamic>;
                  return ListView.separated(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index] as Map<String, dynamic>;
                      return ChatMessage(
                        name: message['name'],
                        time: message['time'],
                        message: message['message'],
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                  );
                }),
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

                        hintText: "Message",
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
