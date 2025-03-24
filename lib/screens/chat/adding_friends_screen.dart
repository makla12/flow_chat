import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddingFriendsScreen extends StatefulWidget {
  const AddingFriendsScreen({super.key});
  @override
  State<AddingFriendsScreen> createState() => _AddingFriendsScreenState();
}

class _AddingFriendsScreenState extends State<AddingFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> searchResults = [];
  List<String> invites = [];
  List<String> friends = [];

  void getFriends() async {
    final curentUser = FirebaseAuth.instance.currentUser;
    if (curentUser == null) return;
    List<String> newFriends = [];
    try{
      final querySnapshot = await FirebaseFirestore.instance.collection('private_chats').where('members', arrayContains: curentUser.uid).get();
      for (final doc in querySnapshot.docs) {
        final members = doc['members'] as List<dynamic>;
        final friendUid = members.firstWhere((uid) => uid != curentUser.uid);
        newFriends.add(friendUid as String);
      }
    } catch (e) {
      print('Błąd pobierania znajomych: $e');
    }
    setState(() {
      friends = newFriends;
    });
  }

  void getInvites() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    List<String> newInvites = [];
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('invites')
              .where('to', isEqualTo: currentUser.uid)
              .get();
      for (final doc in querySnapshot.docs) {
        final invite = doc.data();
        if (invite['type'] == 'friend') {
          newInvites.add(invite['from'] as String);
        }
      }

      final querySnapshot2 =
          await FirebaseFirestore.instance
              .collection('invites')
              .where('from', isEqualTo: currentUser.uid)
              .get();
      for (final doc in querySnapshot2.docs) {
        final invite = doc.data();
        if (invite['type'] == 'friend') {
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

  @override
  void initState() {
    super.initState();
    getInvites();
    getFriends();
    _searchController.addListener(_searchUser);
  }

  Future<void> _searchUser() async {
    final searchText = _searchController.text.trim().toLowerCase();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (searchText.isNotEmpty  && currentUser != null) {
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
    setState(() {
      invites.add(friendUid);
    });

    try {
      await FirebaseFirestore.instance.collection('invites').doc().set({
        'from': currentUser.uid,
        'to': friendUid,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'friend',
      });
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wysłano zaproszenie do znajomych!')),
      );
    } catch (e) {
      print('Błąd przy dodawaniu znajomego: $e');
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wystąpił błąd, spróbuj ponownie.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  nickname: userData['username'] ?? 'Brak nazwy',
                  avatarUrl: userData['avatarUrl'] as String?,
                  onAdd: () => _addFriend(friendUid),
                  canAdd: !invites.contains(friendUid) && !friends.contains(friendUid),
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
  final String nickname;
  final String? avatarUrl;
  final VoidCallback onAdd;
  final bool canAdd;

  const FriendRequestItem({
    super.key,
    required this.nickname,
    required this.avatarUrl,
    required this.onAdd,
    required this.canAdd,
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
      trailing:
          (canAdd
              ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: onAdd,
                child: const Text('Dodaj', style: TextStyle(color: Colors.white)),
              )
              : null),
    );
  }
}
