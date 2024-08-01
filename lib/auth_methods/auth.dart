import 'package:food_recipe_app/models/extended_ingredient.dart';
import 'package:food_recipe_app/models/user_ingredient_list.dart';
import 'package:food_recipe_app/screens/nav/bottom_nav_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:food_recipe_app/auth_methods/firebaseFunctions.dart';

class AuthMethods {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return auth.currentUser;
  }

  static bool isGuestUser(User? user) {
    return user != null && user.isAnonymous;
  }

  static Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await auth.signInAnonymously();
      User? user = userCredential.user;
      if (user != null) {
        await _initializeGuestUserData(user.uid);
      }
      return user;
    } catch (e) {
      print('Error signing in as guest: $e');
      return null;
    }
  }

  static Future<void> _initializeGuestUserData(String uid) async {
    await FirestoreServices.saveUser(
        "Guest User", "guest@example.com", uid, []);
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken);

    UserCredential result = await firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;

    if (result != null) {
      Map<String, dynamic> userInfoMap = {
        "email": userDetails!.email,
        "name": userDetails.displayName,
        "imgUrl": userDetails.photoURL,
        "id": userDetails.uid
      };
      await FirestoreServices.saveUser(
          userDetails.displayName ?? "Guest User",
          userDetails.email ?? "guest@example.com",
          userDetails.uid,
          [ExtendedIngredient()]);
      Provider.of<UserIngredientList>(context, listen: false)
          .loadUserIngredients(userDetails.uid);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const BottomNavView()));
    }
  }
}
