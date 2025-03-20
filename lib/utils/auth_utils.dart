import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthUtils {
  static void onUserLogin() {
    FirebaseMessaging.instance.subscribeToTopic(FirebaseAuth.instance.currentUser!.uid);
  }
  static void addUserToFirestore(String uid, String email, String displayName) async {
    try{
      final userCollection = FirebaseFirestore.instance.collection('users');
      final userDoc = userCollection.doc(uid);
      final userExists = await userDoc.get();
      if (!userExists.exists) {
        await userDoc.set({
          'email': email,
          'username': displayName,
          'avatarUrl':"https://i.pravatar.cc/150?img=1", 
        });
      }
    } catch (e) {
      print("Error adding user to Firestore: $e");
    }
  }
}
