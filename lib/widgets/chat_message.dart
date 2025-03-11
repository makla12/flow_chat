import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key, required this.name, required this.time, required this.message});
  final String name;
  final String time;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        CircleAvatar(backgroundColor: Colors.purple, child: Text(name[0])),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 5,
                children: [Text(style: TextStyle(fontSize: 16), name), Text(style: TextStyle(fontSize: 8), time)],
              ),
              Text(style: TextStyle(fontSize: 14), message),
            ],
          ),
        ),
      ],
    );
  }
}
