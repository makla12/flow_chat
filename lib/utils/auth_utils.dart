import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthUtils {
  static void addUserToFirestore(UserCredential credential) async {
    try{
      final user = credential.user;
      final userCollection = FirebaseFirestore.instance.collection('users');
      final userDoc = userCollection.doc(user?.uid);
      final userExists = await userDoc.get();
      if (!userExists.exists) {
        await userDoc.set({
          'email': user?.email,
          'username': user?.displayName,
          'friends': [],
        });
      }
    } catch (e) {
      print("Error adding user to Firestore: $e");
    }
  }
}
