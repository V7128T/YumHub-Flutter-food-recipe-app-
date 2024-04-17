import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  static saveUser(String name, email, uid) async {
    await FirebaseFirestore.instance
        .collection('email-auth-users')
        .doc(uid)
        .set({'email': email, 'username': name});
  }

  static deleteUser(String name, email, uid) async {
    await FirebaseFirestore.instance
        .collection('email-auth-users')
        .doc(uid)
        .delete();
  }
}
