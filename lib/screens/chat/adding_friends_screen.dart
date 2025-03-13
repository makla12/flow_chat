import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddingFriendsScreen extends StatefulWidget {
  const AddingFriendsScreen({super.key});

  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color appBarColor = Color(0xFF1E3A8A);
  static const Color containerColor = Color(0xFF1F2937);
  static const Color dividerColor = Color(0xFF2F3A4B);
  static const Color buttonColor = Color(0xFF3B82F6);

  @override
  State<AddingFriendsScreen> createState() => _AddingFriendsScreenState();
}

class _AddingFriendsScreenState extends State<AddingFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchUser);
  }

  Future<void> _searchUser() async {
    final searchText = _searchController.text.trim().toLowerCase();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (searchText.length >= 2 && currentUser != null) {
      try {
        final querySnapshot =
            await FirebaseFirestore.instance.collection('users').get();

        setState(() {
          searchResults =
              querySnapshot.docs.where((doc) {
                final username = (doc['username'] as String).toLowerCase();
                return username.startsWith(searchText) &&
                    doc.id != currentUser.uid;
              }).toList();
        });
      } catch (e) {
        print('Błąd wyszukiwania: $e');
      }
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }

  Future<void> _addFriend(String friendUid) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
            'friends': FieldValue.arrayUnion([friendUid]),
          });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dodano do znajomych!')));
    } catch (e) {
      print('Błąd przy dodawaniu znajomego: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wystąpił błąd, spróbuj ponownie.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AddingFriendsScreen.backgroundColor,
      appBar: AppBar(
        backgroundColor: AddingFriendsScreen.appBarColor,
        title: const Text('FlowChat', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                var userData =
                    searchResults[index].data() as Map<String, dynamic>;
                final friendUid = searchResults[index].id;
                return FriendRequestItem(
                  uid: friendUid,
                  nickname: userData['username'] ?? 'Brak nazwy',
                  avatarUrl: userData['avatarUrl'] as String?,
                  onAdd: () => _addFriend(friendUid),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FriendRequestItem extends StatelessWidget {
  final String uid;
  final String nickname;
  final String? avatarUrl;
  final VoidCallback onAdd;

  const FriendRequestItem({
    super.key,
    required this.uid,
    required this.nickname,
    required this.avatarUrl,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple,
        backgroundImage:
            avatarUrl != null && avatarUrl!.isNotEmpty
                ? NetworkImage(avatarUrl!)
                : null,
        child:
            avatarUrl == null || avatarUrl!.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
      ),
      title: Text(nickname, style: const TextStyle(color: Colors.white)),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AddingFriendsScreen.buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onAdd,
        child: const Text('Add', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
