import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:food_recipe_app/models/removed_ingredients.dart';

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

  static Future<void> saveDeleteHistory(
      String userId,
      List<RemovedIngredient> removedIngredients,
      List<Recipe> deletedRecipes) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'deleteHistory': {
        'removedIngredients':
            removedIngredients.map((i) => i.toJson()).toList(),
        'deletedRecipes': deletedRecipes.map((r) => r.toJson()).toList(),
      }
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>> loadDeleteHistory(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = doc.data();
    if (data != null && data.containsKey('deleteHistory')) {
      return data['deleteHistory'];
    }
    if (kDebugMode) {
      print('No delete history found.');
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

  static Future<void> permanentlyRemoveIngredient(
      String userId, String recipeId, String ingredientId) async {
    try {
      // Get a reference to the user's document
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Get the current recipe data
      final userDoc = await userDocRef.get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final recipesData = userDoc.data()?['recipes'] as Map<String, dynamic>?;
      if (recipesData == null || !recipesData.containsKey(recipeId)) {
        throw Exception('Recipe not found');
      }

      final recipeData = recipesData[recipeId] as Map<String, dynamic>;
      final ingredients = recipeData['extendedIngredients'] as List<dynamic>?;

      if (ingredients == null) {
        throw Exception('Ingredients list not found');
      }

      // Remove the ingredient with the matching ID
      ingredients
          .removeWhere((ingredient) => ingredient['uniqueId'] == ingredientId);

      // Update the recipe data in Firestore
      await userDocRef.update({
        'recipes.$recipeId.extendedIngredients': ingredients,
      });

      // Remove from recently deleted ingredients if it exists
      final deletedIngredientsData =
          userDoc.data()?['recentlyDeletedIngredients'] as List<dynamic>?;
      if (deletedIngredientsData != null) {
        deletedIngredientsData.removeWhere((ingredient) =>
            ingredient['recipeId'] == recipeId &&
            ingredient['uniqueId'] == ingredientId);

        await userDocRef.update({
          'recentlyDeletedIngredients': deletedIngredientsData,
        });
      }

      if (kDebugMode) {
        print('Ingredient permanently removed from Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error permanently removing ingredient: $e');
      }
      rethrow;
    }
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
