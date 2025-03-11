import 'package:flutter/material.dart';
import 'package:flow_chat/widgets/chat_message.dart';

class PrivateChat extends StatefulWidget {
  const PrivateChat({super.key});

  @override
  PrivateChatState createState() => PrivateChatState();
}

class PrivateChatState extends State<PrivateChat> {
  final TextEditingController textController = TextEditingController();
  final String chatName = "Kajetan kraska";
  final List<Map<String, String>> messages = [
    {
      "name": "Rudy cel",
      "time": "Dzisiaj 21:37",
      "message": "To nie prawda",
    },
    {
      "name": "Kajetan kraska",
      "time": "Dzisiaj 21:37",
      "message": "Papież nie żyje",
    },
    {
      "name": "Kajetan kraska",
      "time": "Dzisiaj 21:37",
      "message": "Papież nie żyje",
    },
    {
      "name": "Kajetan kraska",
      "time": "Dzisiaj 21:37",
      "message": "Papież nie żyje",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                spacing: 10,
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back)),
                  CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Text(chatName[0]),
                  ),
                  Text(chatName, style: TextStyle(fontSize: 20)),
                ],
              ),
            ),

            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xff2d3748))),
                ),
                child: ListView.separated(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ChatMessage(
                      name: messages[index]["name"]!,
                      time: messages[index]["time"]!,
                      message: messages[index]["message"]!,
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 10),
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

                        hintText: "Message",
                      ),
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.send)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
