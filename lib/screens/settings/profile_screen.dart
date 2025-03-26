import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pamiętaj o dodaniu google_sign_in do pubspec.yaml

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool isLightMode = false;

  String _username = "Ładowanie...";
  String _avatarUrl = "";

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _loadPreferences();
  }

  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc['username'] ?? "User Name";
          _avatarUrl =
              userDoc['avatarUrl'] ?? "https://i.pravatar.cc/150?img=1";
        });
      }
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLightMode = prefs.getBool('isLightMode') ?? false;
    });
  }

  Future<void> _updateUsername(String newName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'username': newName});
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
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'avatarUrl': newUrl});
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Twój profil'),
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
                    backgroundImage:
                        _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(_username, style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: Icon(Icons.image),
            title: Text('Zmień awatar'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: _showAvatarDialog,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Zmień nazwę użytkownika'),
            trailing: Icon(Icons.arrow_forward_ios),
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
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: [
                for (var i = 0; i < 71; i++)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150?img=$i",
                      ),
                    ),
                    title: Text('Awatar $i'),
                    onTap: () async {
                      await _updateAvatarUrl("https://i.pravatar.cc/150?img=$i");
                      setState(() {
                        _avatarUrl = "https://i.pravatar.cc/150?img=$i";
                      });
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
              ],
            ),
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
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }
}
