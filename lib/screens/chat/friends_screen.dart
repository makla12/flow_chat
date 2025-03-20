import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flow_chat/screens/chat/notifications.dart';
import 'package:flow_chat/screens/chat/private_chat_screen.dart';
import 'package:flow_chat/screens/chat/adding_friends_screen.dart';
import 'package:flow_chat/widgets/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final Stream<QuerySnapshot> _privateChatStream =
      FirebaseFirestore.instance
          .collection('private_chats')
          .where(
            'members',
            arrayContains: FirebaseAuth.instance.currentUser!.uid,
          )
          .snapshots();

  final TextEditingController _searchController = TextEditingController();

  // Ustawienia wyglądu
  bool isLightMode = false;
  double fontSize = 14.0;
  Color accentColor = Colors.blue;

  // Gettery dynamicznych kolorów
  Color get backgroundColor =>
      isLightMode ? Colors.white : const Color(0xFF0F172A);
  Color get appBarColor =>
      isLightMode ? Colors.blueGrey : const Color(0xFF1E3A8A);
  Color get dividerColor => isLightMode ? Colors.grey : const Color(0xFF2F3A4B);
  Color get searchFillColor =>
      isLightMode ? Colors.grey.shade300 : Colors.grey.shade900;
  Color get textColor => isLightMode ? Colors.black : Colors.white;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Ładowanie ustawień wyglądu z SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLightMode = prefs.getBool('isLightMode') ?? false;
      fontSize = prefs.getDouble('fontSize') ?? 14.0;
      int savedColor = prefs.getInt('accentColor') ?? Colors.blue.value;
      accentColor = Color(savedColor);
    });
  }

  // Zapis trybu jasnego
  Future<void> _saveLightMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLightMode', value);
  }

  // Przełączanie trybu jasnego
  void toggleLightMode() {
    setState(() {
      isLightMode = !isLightMode;
    });
    _saveLightMode(isLightMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'FlowChat',
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddingFriendsScreen(),
                ),
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
              controller: _searchController,
              style: TextStyle(color: textColor, fontSize: fontSize),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: textColor),
                hintText: 'Szukaj',
                hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                fillColor: searchFillColor,
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
                  return Center(
                    child: Text(
                      'Nie znaleziono znajomych',
                      style: TextStyle(color: textColor, fontSize: fontSize),
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
                    final friendId = friends[index]['members'].firstWhere(
                      (element) =>
                          element != FirebaseAuth.instance.currentUser!.uid,
                    );
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
                          return const SizedBox();
                        }
                        if (!snapshot.hasData ||
                            snapshot.data!.data() == null) {
                          return const Text("Brak danych");
                        }
                        final friendData =
                            snapshot.data!.data()! as Map<String, dynamic>;
                        final friendName = friendData['username'] as String;
                        final friendAvatarUrl =
                            friendData['avatarUrl'] as String;
                        final bool isReed = friends[index]['reed'].contains(
                          FirebaseAuth.instance.currentUser!.uid,
                        );
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(friendAvatarUrl),
                          ),
                          title: Text(
                            friendName,
                            style:
                                !isReed
                                    ? TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: fontSize,
                                      color: textColor,
                                    )
                                    : TextStyle(
                                      fontSize: fontSize,
                                      color: textColor,
                                    ),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                friends[index]['lastMessage']['name'] ==
                                        FirebaseAuth.instance.currentUser!.uid
                                    ? 'Ty: '
                                    : '',
                                style:
                                    !isReed
                                        ? TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSize,
                                          color: textColor,
                                        )
                                        : TextStyle(
                                          fontSize: fontSize,
                                          color: textColor,
                                        ),
                              ),
                              Text(
                                friends[index]['lastMessage']['message'],
                                style:
                                    !isReed
                                        ? TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSize,
                                          color: textColor,
                                        )
                                        : TextStyle(
                                          fontSize: fontSize,
                                          color: textColor,
                                        ),
                              ),
                            ],
                          ),
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
        backgroundColor: backgroundColor,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.white70,
        dividerColor: dividerColor,
      ),
    );
  }
}
