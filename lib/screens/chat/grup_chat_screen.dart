import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'create_server_screen.dart';

import '../../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final Stream<QuerySnapshot> _serversStream =
      FirebaseFirestore.instance.collection('teams').where("members", arrayContains: FirebaseAuth.instance.currentUser!.uid).snapshots();

  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color appBarColor = Color(0xFF1E3A8A);
  static const Color containerColor = Color(0xFF1F2937);
  static const Color dividerColor = Color(0xFF2F3A4B);
  static const Color logoutColor = Color(0xFFE53935);

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
            icon: const Icon(Icons.add_home, color: Colors.white),
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
              decoration: InputDecoration(
                hintText: 'Szukaj',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade900,
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
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final server = snapshot.data!.docs[index];
                    return ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.grey),
                      title: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ChatScreen(groupName: server['name']),
                            ),
                          );
                        },
                        child: Container(
                          height: 30,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              server['name'],
                              style: TextStyle(
                                color: Colors.white,
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
        currentIndex: 0, // Podświetlamy przycisk "Menu"
        backgroundColor: backgroundColor,
        selectedItemColor: const Color.fromARGB(255, 63, 146, 255),
        unselectedItemColor: Colors.white70,
        dividerColor: dividerColor,
      ),
    );
  }
}
