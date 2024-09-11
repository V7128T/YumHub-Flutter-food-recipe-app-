import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount == null)
        return; // User canceled the sign-in process

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result =
          await firebaseAuth.signInWithCredential(credential);
      User? userDetails = result.user;

      if (userDetails != null) {
        // Check if the user already exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userDetails.uid)
            .get();

        if (!userDoc.exists) {
          // If the user doesn't exist, create a new user profile
          await FirestoreServices.saveUser(
            userDetails.displayName ?? "Google User",
            userDetails.email ?? "googleuser@example.com",
            userDetails.uid,
            [], // Empty list of ingredients for new users
          );
        }

        // Load user ingredients
        await Provider.of<UserIngredientList>(context, listen: false)
            .loadUserIngredients(userDetails.uid);

        // Navigate to the main screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavView()),
        );
      }
    } catch (error) {
      print("Error signing in with Google: $error");
      // You might want to show an error message to the user here
    }
  }
}
