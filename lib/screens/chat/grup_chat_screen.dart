import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_chat/widgets/notifications_button.dart';
import 'package:flow_chat/widgets/server_reed_icon.dart';
import 'package:flutter/material.dart';
import 'chanels_screen.dart';
import 'create_server_screen.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.setThemeMode});
  final Function(ThemeMode) setThemeMode;

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

  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlowChat'),
        centerTitle: false,
        actions: [
          NotificationsButton(userId: FirebaseAuth.instance.currentUser!.uid,),
          IconButton(
            icon: const Icon(Icons.add_home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateServerScreen()),
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
                hintText: 'Szukaj',
                prefixIcon: const Icon(Icons.search),
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
              stream: _serversStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Brak serwerów",
                    ),
                  );
                }

                final filteredDocs =
                    snapshot.data!.docs.where((doc) {
                      final String name = doc['name'].toString().toLowerCase();
                      return name.contains(searchQuery);
                    }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nie znaleziono serwerów",
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final server = filteredDocs[index];
                    return ListTile(
                      trailing: ServerReedIcon(serverSnapshot: server,),
                      leading: (server['muted'] as List<dynamic>).contains(FirebaseAuth.instance.currentUser!.uid)
                          ? const Icon(Icons.notifications_off)
                          : const Icon(Icons.home),
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
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              server['name'],
                              style: TextStyle(
                                fontSize: 16,
                              ),
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
        setThemeMode: widget.setThemeMode,
      ),
    );
  }
}
