import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUser(String userId, Map<String, dynamic> userInfoMap) {
    return FirebaseFirestore.instance
        .collection("google-auth-users")
        .doc(userId)
        .set(userInfoMap);
  }
}
