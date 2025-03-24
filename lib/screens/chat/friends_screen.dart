import 'package:flow_chat/screens/chat/notifications.dart';
import 'package:flow_chat/screens/chat/private_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'adding_friends_screen.dart';

class FriendsScreen extends StatelessWidget {
  FriendsScreen({super.key, required this.setThemeMode});
  final Function(ThemeMode) setThemeMode;

  final Stream<QuerySnapshot> _privateChatStream =
      FirebaseFirestore.instance
          .collection('private_chats')
          .where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .snapshots();
  void _showFriendDeleteDialog(context, DocumentReference chatRefrence) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usuń znajomego'),
          content: const Text('Czy na pewno chcesz usunąć znajomego?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () {
                chatRefrence.delete();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );
  }

  void _showFriendMenu(context, DocumentSnapshot chatSnapshot) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (chatSnapshot['muted'].contains(FirebaseAuth.instance.currentUser!.uid))
                ? ListTile(
                  title: const Text('Włącz powiadomienia'),
                  trailing: const Icon(Icons.notifications),
                  onTap: () {
                    chatSnapshot.reference.update({
                      'muted': FieldValue.arrayRemove([
                        FirebaseAuth.instance.currentUser!.uid,
                      ]),
                    });
                    Navigator.pop(context);
                  },
                )
                : ListTile(
                  title: const Text('Wyłącz powiadomienia'),
                  trailing: const Icon(Icons.notifications_off),
                  onTap: () {
                    chatSnapshot.reference.update({
                      'muted': FieldValue.arrayUnion([
                        FirebaseAuth.instance.currentUser!.uid,
                      ]),
                    });
                    Navigator.pop(context);
                  },
                ),
            (chatSnapshot['reed'].contains(
                  FirebaseAuth.instance.currentUser!.uid,
                ))
                ? ListTile(
                  title: const Text('Oznacz jako nieprzeczytane'),
                  trailing: const Icon(Icons.close),
                  onTap: () {
                    chatSnapshot.reference.update({
                      'reed': FieldValue.arrayRemove([
                        FirebaseAuth.instance.currentUser!.uid,
                      ]),
                    });
                    Navigator.pop(context);
                  },
                )
                : ListTile(
                  title: const Text('Oznacz jako przeczytane'),
                  trailing: const Icon(Icons.check),
                  onTap: () {
                    chatSnapshot.reference.update({
                      'reed': FieldValue.arrayUnion([
                        FirebaseAuth.instance.currentUser!.uid,
                      ]),
                    });
                    Navigator.pop(context);
                  },
                ),
            ListTile(
              trailing: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Usuń znajomego',
                style: TextStyle(color: Colors.red),
              ),
              onTap:
                  () =>
                      _showFriendDeleteDialog(context, chatSnapshot.reference),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlowChat', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddingFriendsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Szukaj',
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _privateChatStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nie znaleziono znajomych',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                final friends = snapshot.data!.docs;
                friends.sort((a, b) {
                  final aTime = (a['lastMessage']['time'] as Timestamp);
                  final bTime = (b['lastMessage']['time'] as Timestamp);
                  return bTime.compareTo(aTime);
                });
                return ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friendId = friends[index]['members']
                        .firstWhere((element) =>
                            element != FirebaseAuth.instance.currentUser!.uid);
                    final friendStream =
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(friendId)
                            .snapshots();

                    return StreamBuilder<DocumentSnapshot>(
                      stream: friendStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: SizedBox());
                        }
                        if (!snapshot.hasData ||
                            snapshot.data!.data() == null) {
                          return Text("Brak danych");
                        }
                        final friendData =
                            snapshot.data!.data()! as Map<String, dynamic>;
                        final friendName = friendData['username'] as String;
                        final friendAvatarUrl =
                            friendData['avatarUrl'] as String;
                        final bool isReed = friends[index]['reed'].contains(FirebaseAuth.instance.currentUser!.uid);
                        return ListTile(
                          trailing: friends[index]['muted'].contains(
                            FirebaseAuth.instance.currentUser!.uid,
                          )
                              ? const Icon(Icons.notifications_off)
                              : null,
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(friendAvatarUrl),
                          ),
                          title: Text(friendName, style: !isReed ? const TextStyle(fontWeight: FontWeight.bold) : null),
                          subtitle: Row(
                            children: [
                              Text(friends[index]['lastMessage']['name'] == FirebaseAuth.instance.currentUser!.uid
                                  ? 'Ty: '
                                  : ''),
                              Text(friends[index]['lastMessage']['message'], style: !isReed
                                  ? const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                                  : null),
                            ],
                          ),
                          onLongPress:
                              () => _showFriendMenu(context, friends[index]),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PrivateChatScreen(
                                      privateChatRef: friends[index].reference,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        backgroundColor: Colors.white24,
        selectedItemColor: const Color.fromARGB(255, 63, 146, 255),
        unselectedItemColor: Colors.white70,
        dividerColor: Colors.white24,
        setThemeMode: setThemeMode
      ),
    );
  }
}
