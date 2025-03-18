import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow_chat/screens/chat/adding_friends_screen.dart';
import 'package:flutter/material.dart';

class InviteToServerScreen extends StatefulWidget {
  const InviteToServerScreen({super.key, required this.serverId});
  final String serverId;

  @override
  InviteToServerScreenState createState() => InviteToServerScreenState();
}

class InviteToServerScreenState extends State<InviteToServerScreen> {
  final Color backgroundColor = Color(0xFF0F172A);
  final Color appBarColor = Color(0xFF1E3A8A);
  List<DocumentSnapshot> searchResults = [];
  List<String> invites = [];

  final _searchController = TextEditingController();

  void _getInvites() async {
    List<String> newInvites = [];
    try{
      final querySnapshot = await FirebaseFirestore.instance
          .collection('invites')
          .where('from', isEqualTo: widget.serverId)
          .get();
      for (final doc in querySnapshot.docs) {
        final invite = doc.data();
        if (invite['type'] == 'server') {
          newInvites.add(invite['to'] as String);
        }
      }
    } catch (e) {
      print('Błąd pobierania zaproszeń: $e');
    }
    setState(() {
      invites = newInvites;
    });
  }

  void _searchUsers() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;
    try{
      final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      final membersSnapshot = await FirebaseFirestore.instance.collection('teams').doc(widget.serverId).get();
      final members = membersSnapshot.data()!['members'];
      setState(() {
        searchResults = querySnapshot.docs.where((doc) {
          final username = doc['username'].toString().toLowerCase();
          return username.startsWith(query) && !members.contains(doc.id);
        }).toList();
      });
    } catch (e) {
      print('Błąd pobierania użytkowników: $e');
    }
  }

  void _inviteToServer(String uid) async {
    setState(() {
      invites.add(uid);
    });

    try {
      await FirebaseFirestore.instance.collection('invites').doc().set({
        'from': widget.serverId,
        'to': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'server',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wysłano zaproszenie do serwera!')),
      );
    } catch (e) {
      print('Błąd przy dodawaniu znajomego: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wystąpił błąd, spróbuj ponownie.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getInvites();
    _searchController.addListener(_searchUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text('Zaproś do serwera'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Wpisz nazwę użytkownika...',
                fillColor: Colors.grey.shade900,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              var username = searchResults[index]['username'];
              var imageUrl = searchResults[index]['avatarUrl'];
              var canAdd = !invites.contains(searchResults[index].id);
              return FriendRequestItem(nickname: username, avatarUrl: imageUrl, onAdd: () => _inviteToServer(searchResults[index].id), canAdd: canAdd);
            },
          ))
        ],
      ),
    );
  }
}