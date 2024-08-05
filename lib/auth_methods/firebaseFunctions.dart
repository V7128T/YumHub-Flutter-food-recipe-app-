import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';
import 'package:food_recipe_app/models/recipe.dart';

class FirestoreServices {
  static saveUser(String email, String uid, String name,
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

  static deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }

  static Future<void> saveUserRecipe(
      String userId, String recipeId, Recipe recipe) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'recipes': {recipeId: recipe.toJson()}
    }, SetOptions(merge: true));
  }

  static Future<Recipe> getRecipe(String userId, String recipeId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final recipeData = doc.data()?['recipes'][recipeId];
    return Recipe.fromJson(recipeData);
  }

  static Future<void> removeUserRecipe(String userId, String recipeId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'recipes.$recipeId': FieldValue.delete()});
  }

  static Future<Map<String, Set<ExtendedIngredient>>> loadUserIngredients(
      String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final ingredientsData =
          userDoc.data()?['ingredients'] as Map<String, dynamic>?;
      if (ingredientsData != null) {
        return ingredientsData.map((recipeId, ingredientsList) {
          return MapEntry(
            recipeId,
            (ingredientsList as List<dynamic>)
                .map((json) => ExtendedIngredient.fromJson(json))
                .toSet(),
          );
        });
      }
    }
    return {};
  }

  static Future<void> permanentlyRemoveUserRecipe(
      String userId, String recipeId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('deletedRecipes')
        .doc(recipeId)
        .delete();
  }

  static Future<void> clearAllDeletedRecipes(String userId) async {
    final deletedRecipesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('deletedRecipes');

    final deletedRecipes = await deletedRecipesRef.get();
    for (var doc in deletedRecipes.docs) {
      await doc.reference.delete();
    }
  }

  static Future<void> removeFromDeletedRecipes(
      String userId, String recipeId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('deletedRecipes')
        .doc(recipeId)
        .delete();
  }
}
