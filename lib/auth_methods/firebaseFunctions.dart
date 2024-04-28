import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  static saveUser(String name, email, uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email,
      'id': uid,
      'name': name,
      'imgUrl': "assets/default-pfp.jpg"
    });
  }

  static deleteUser(String name, email, uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }
}
