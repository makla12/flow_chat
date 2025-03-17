import 'package:flow_chat/screens/chat/notifications.dart';
import 'package:flow_chat/screens/chat/private_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'adding_friends_screen.dart';

class FriendsScreen extends StatefulWidget {
  FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final Stream<DocumentSnapshot> _friendsStream =
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();

  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Set<String> matchingFriends = Set();

  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color appBarColor = Color(0xFF1E3A8A);
  static const Color containerColor = Color(0xFF1F2937);
  static const Color dividerColor = Color(0xFF2F3A4B);
  static const Color logoutColor = Color(0xFFE53935);

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
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
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
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
            child: StreamBuilder<DocumentSnapshot>(
              stream: _friendsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.data() == null) {
                  return const Center(
                    child: Text(
                      'No friends found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                final data = snapshot.data!.data()! as Map<String, dynamic>;
                final friends = data['friends'] as List<dynamic>;

                if (friends.isEmpty) {
                  return const Center(
                    child: Text(
                      'No friends found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return StatefulBuilder(
                  builder: (context, setState) {
                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friendId = friends[index];
                        final friendStream =
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(friendId)
                                .snapshots();

                        return StreamBuilder<DocumentSnapshot>(
                          stream: friendStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.data() == null) {
                              return const SizedBox.shrink();
                            }

                            final friendData =
                                snapshot.data!.data()! as Map<String, dynamic>;
                            final friendName =
                                friendData['username'].toString().toLowerCase();
                            final shouldShow = friendName.contains(searchQuery);

                            if (!shouldShow) return const SizedBox.shrink();

                            final friendAvatarUrl =
                                friendData['avatarUrl'] as String;
                            final privateChatId = [
                              FirebaseAuth.instance.currentUser!.uid,
                              friendId,
                            ];
                            privateChatId.sort();
                            final privateChatIdString = privateChatId.join('_');

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(friendAvatarUrl),
                              ),
                              title: Text(friendData['username']),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PrivateChatScreen(
                                          privateChatId: privateChatIdString,
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
                );
              },
            ),
          ),
          if (matchingFriends.isEmpty && searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Nie znaleziono znajomych',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        backgroundColor: backgroundColor,
        selectedItemColor: const Color.fromARGB(255, 63, 146, 255),
        unselectedItemColor: Colors.white70,
        dividerColor: dividerColor,
      ),
    );
  }
}
