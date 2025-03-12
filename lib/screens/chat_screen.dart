import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String groupName;

  const ChatScreen({super.key, required this.groupName});

  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color appBarColor = Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(groupName, style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Text(
          'Czat grupowy: $groupName',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

// class ChatBubble extends StatelessWidget {
//   final String message;
//   ChatBubble(this.message);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(child: Text("K")),
//           SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Kajetan sigma kraska",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Text(message),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChatInputField extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: "Wiadomość",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 filled: true,
//               ),
//             ),
//           ),
//           IconButton(icon: Icon(Icons.send), onPressed: () {}),
//         ],
//       ),
//     );
//   }
// }
