import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_chat/widgets/server_reed_icon.dart';
import 'package:flutter/material.dart';
import 'chanels_screen.dart';
import 'create_server_screen.dart';
import 'notifications.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Stream<QuerySnapshot> _serversStream =
      FirebaseFirestore.instance
          .collection('teams')
          .where(
            "members",
            arrayContains: FirebaseAuth.instance.currentUser!.uid,
          )
          .snapshots();

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Dynamiczne ustawienia wyglądu
  bool isLightMode = false;
  double fontSize = 14.0;
  Color accentColor = Colors.blue;

  // Gettery dynamicznych kolorów
  Color get backgroundColor =>
      isLightMode ? Colors.white : const Color(0xFF0F172A);
  Color get appBarColor =>
      isLightMode ? Colors.blueGrey : const Color(0xFF1E3A8A);
  Color get dividerColor => isLightMode ? Colors.grey : const Color(0xFF2F3A4B);
  Color get textColor => isLightMode ? Colors.black : Colors.white;
  Color get searchFillColor =>
      isLightMode ? Colors.grey.shade300 : Colors.grey.shade900;
  Color get iconColor => isLightMode ? Colors.black : Colors.white;

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

  // Przełączanie trybu jasnego/ciemnego
  void toggleLightMode() {
    setState(() {
      isLightMode = !isLightMode;
    });
    _saveLightMode(isLightMode);
  }

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
        title: Text(
          'FlowChat',
          style: TextStyle(color: iconColor, fontSize: fontSize),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: iconColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add_home, color: iconColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateServerScreen()),
              );
            },
          ),

          // Przycisk przełączający tryb jasny/ciemny
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
              style: TextStyle(color: textColor, fontSize: fontSize),
              decoration: InputDecoration(
                hintText: 'Szukaj',
                hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: iconColor),
                filled: true,
                fillColor: searchFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _serversStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "Brak serwerów",
                      style: TextStyle(color: textColor, fontSize: fontSize),
                    ),
                  );
                }

                final filteredDocs =
                    snapshot.data!.docs.where((doc) {
                      final String name = doc['name'].toString().toLowerCase();
                      return name.contains(searchQuery);
                    }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      "Nie znaleziono serwerów",
                      style: TextStyle(color: textColor, fontSize: fontSize),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final server = filteredDocs[index];
                    return ListTile(
                      trailing: ServerReedIcon(serverSnapshot: server),
                      leading: Icon(Icons.home, color: iconColor),
                      title: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChannelsScreen(
                                    serverId: server.id,
                                    ownerId: server["ownerId"],
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          height: 30,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: searchFillColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              server['name'],
                              style: TextStyle(color: textColor, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        backgroundColor: backgroundColor,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.white70,
        dividerColor: dividerColor,
      ),
    );
  }
}
