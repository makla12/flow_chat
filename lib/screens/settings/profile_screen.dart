import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color appBarColor = Color(0xFF1E3A8A);
  static const Color backgroundColor = Color(0xFF0F172A);

  String _username = "Ładowanie...";
  String _avatarUrl = "Ładowanie...";

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc['username'] ?? "User Name";
          _avatarUrl = userDoc['avatarUrl'] ?? "https://i.pravatar.cc/150?img=1";
        });
      }
    }
  }

  Future<void> _updateUsername(String newName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'username': newName});
        await user.updateDisplayName(newName);
        await user.reload();
      } catch (e) {
        debugPrint('Error updating username: $e');
      }
    }
  }

  Future<void> _updateAvatarUrl(String newUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'avatarUrl': newUrl});
        setState(() {
          _avatarUrl = newUrl;
        });
      } catch (e) {
        debugPrint('Error updating avatar URL: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Twój profil', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showAvatarDialog,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_avatarUrl),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _username,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.image, color: Colors.white),
            title: const Text('Zmień awatar', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: _showAvatarDialog,
          ),
          const Divider(color: Colors.white54),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Zmień nazwę użytkownika', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: _showUsernameDialog,
          ),
        ],
      ),
    );
  }

  void _showAvatarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Wybierz awatar'),
          content: ListView(
            children: [
              for(var i = 0; i < 71; i++) 
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=$i"),
                  ),
                  title: Text('Awatar $i'),
                  onTap: () async {
                    await _updateAvatarUrl("https://i.pravatar.cc/150?img=$i");
                    setState(() {
                      _avatarUrl = "https://i.pravatar.cc/150?img=$i";
                    });
                    Navigator.pop(context);
                  },
                )
            ],
          ),
        );
      },
    );
  }

  void _showUsernameDialog() {
    TextEditingController controller = TextEditingController(text: _username);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Zmień nazwę użytkownika'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Wpisz nową nazwę użytkownika',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text;
                await _updateUsername(newName);
                setState(() {
                  _username = newName;
                });
                Navigator.pop(context);
              },
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }
}