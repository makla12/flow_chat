import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InviteToServerScreen extends StatefulWidget {
  const InviteToServerScreen({super.key, required this.serverId});
  final String serverId;

  @override
  InviteToServerScreenState createState() => InviteToServerScreenState();
}

class InviteToServerScreenState extends State<InviteToServerScreen> {
  List<DocumentSnapshot> searchResults = [];
  List<String> invites = [];
  final _searchController = TextEditingController();

  // Dynamiczne ustawienia wyglądu
  bool isLightMode = false;
  double fontSize = 14.0;
  Color accentColor = Colors.blue;

  // Gettery dynamicznych kolorów
  Color get backgroundColor =>
      isLightMode ? Colors.white : const Color(0xFF0F172A);
  Color get appBarColor =>
      isLightMode ? Colors.blueGrey : const Color(0xFF1E3A8A);
  Color get searchFillColor =>
      isLightMode ? Colors.grey.shade300 : Colors.grey.shade900;
  Color get textColor => isLightMode ? Colors.black : Colors.white;
  Color get iconColor => isLightMode ? Colors.black : Colors.white;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _getInvites();
    _searchController.addListener(_searchUsers);
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

  void _getInvites() async {
    List<String> newInvites = [];
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('invites')
              .where('from', isEqualTo: widget.serverId)
              .get();
      for (final doc in querySnapshot.docs) {
        final invite = doc.data();
        if (invite['type'] == 'server') {
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

  void _searchUsers() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final membersSnapshot =
          await FirebaseFirestore.instance
              .collection('teams')
              .doc(widget.serverId)
              .get();
      final members = membersSnapshot.data()!['members'];
      setState(() {
        searchResults =
            querySnapshot.docs.where((doc) {
              final username = doc['username'].toString().toLowerCase();
              return username.startsWith(query) && !members.contains(doc.id);
            }).toList();
      });
    } catch (e) {
      print('Błąd pobierania użytkowników: $e');
    }
  }

  void _inviteToServer(String uid) async {
    setState(() {
      invites.add(uid);
    });
    try {
      await FirebaseFirestore.instance.collection('invites').doc().set({
        'from': widget.serverId,
        'to': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'server',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wysłano zaproszenie do serwera!')),
      );
    } catch (e) {
      print('Błąd przy dodawaniu znajomego: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wystąpił błąd, spróbuj ponownie.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'Zaproś do serwera',
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor, fontSize: fontSize),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: iconColor),
                hintText: 'Wpisz nazwę użytkownika...',
                hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
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
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                var username = searchResults[index]['username'];
                var imageUrl = searchResults[index]['avatarUrl'];
                var canAdd = !invites.contains(searchResults[index].id);
                return FriendRequestItem(
                  nickname: username,
                  avatarUrl: imageUrl,
                  onAdd: () => _inviteToServer(searchResults[index].id),
                  canAdd: canAdd,
                  textColor: textColor,
                  buttonColor: accentColor,
                  fontSize: fontSize,
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
  final String avatarUrl;
  final VoidCallback onAdd;
  final bool canAdd;
  final Color textColor;
  final Color buttonColor;
  final double fontSize;

  const FriendRequestItem({
    super.key,
    required this.nickname,
    required this.avatarUrl,
    required this.onAdd,
    required this.canAdd,
    required this.textColor,
    required this.buttonColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
        child: avatarUrl.isEmpty ? Icon(Icons.person, color: textColor) : null,
      ),
      title: Text(
        nickname,
        style: TextStyle(color: textColor, fontSize: fontSize),
      ),
      trailing:
          canAdd
              ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: onAdd,
                child: Text(
                  'Dodaj',
                  style: TextStyle(color: textColor, fontSize: fontSize),
                ),
              )
              : null,
    );
  }
}
