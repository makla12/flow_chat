import 'package:cloud_firestore/cloud_firestore.dart';

class AuthUtils {
  static void addUserToFirestore(String uid, String email, String displayName) async {
    try{
      final userCollection = FirebaseFirestore.instance.collection('users');
      final userDoc = userCollection.doc(uid);
      final userExists = await userDoc.get();
      if (!userExists.exists) {
        await userDoc.set({
          'email': email,
          'username': displayName,
          'friends': [],
          'avatarUrl':"https://i.pravatar.cc/150?img=1", 
        });
      }
    } catch (e) {
      print("Error adding user to Firestore: $e");
    }
  }
}
