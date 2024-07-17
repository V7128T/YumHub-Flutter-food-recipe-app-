import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';

class FirestoreServices {
  static saveUser(String name, email, uid,
      List<ExtendedIngredient> initialIngredients) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email,
      'id': uid,
      'name': name,
      'imgUrl': "assets/default-pfp.jpg",
      'ingredients':
          initialIngredients.map((ingredient) => ingredient.toJson()).toList(),
    });
  }

  static deleteUser(String name, email, uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }

  static saveUserIngredients(
      String uid, List<ExtendedIngredient> ingredients) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'ingredients':
          ingredients.map((ingredient) => ingredient.toJson()).toList()
    });
  }
}
