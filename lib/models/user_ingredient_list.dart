import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';
import 'package:food_recipe_app/models/categorized_ingredients.dart';
import 'package:food_recipe_app/auth_methods/firebaseFunctions.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:food_recipe_app/models/shopping_list_item.dart';
import 'package:food_recipe_app/services/conversion_service.dart';
import 'removed_ingredients.dart';

class UserIngredientList extends ChangeNotifier {
  final Map<String, Recipe> _userRecipes = {};
  final List<Recipe> _recentlyDeletedRecipes = [];
  final ConversionService _conversionService = ConversionService();
  final List<RemovedIngredient> _recentlyRemovedIngredients = [];

  Map<String, Recipe> get userRecipes => _userRecipes;

  List<RecipeInfo> get recipeInfoList => _userRecipes.values
      .map((recipe) => RecipeInfo.fromRecipe(recipe))
      .toList();

  Map<String, List<ExtendedIngredient>> get combinedIngredients {
    final combinedIngredients = <String, List<ExtendedIngredient>>{};
    for (final recipe in _userRecipes.values) {
      for (final ingredient in recipe.extendedIngredients ?? []) {
        final name = ingredient.name ?? '';
        combinedIngredients.putIfAbsent(name, () => []).add(ingredient);
      }
    }
    return combinedIngredients;
  }

  Future<void> convertIngredients() async {
    for (var recipe in _userRecipes.values) {
      if (recipe.extendedIngredients != null) {
        for (var ingredient in recipe.extendedIngredients!) {
          await ingredient.convertToGrams(_conversionService);
        }
      }
    }
    notifyListeners();
  }

  Future<void> updateIngredient(String userId, String recipeId,
      ExtendedIngredient updatedIngredient, String recipeTitle) async {
    if (_userRecipes.containsKey(recipeId)) {
      final recipe = _userRecipes[recipeId];
      if (recipe != null) {
        final ingredients = recipe.extendedIngredients?.toList() ?? [];
        print(
            "Searching for ingredient with uniqueId: ${updatedIngredient.uniqueId}");
        print("Current ingredients: ${ingredients.map((e) => e.uniqueId)}");
        final index = ingredients
            .indexWhere((i) => i.uniqueId == updatedIngredient.uniqueId);

        if (index != -1) {
          // Convert only the updated ingredient
          await updatedIngredient.convertToGrams(_conversionService);

          ingredients[index] = updatedIngredient;
          recipe.extendedIngredients = ingredients;
          _userRecipes[recipeId] = recipe;

          notifyListeners();

          // Update Firestore
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({
              'recipes.$recipeId': recipe.toJson(),
            });
            print('Firestore updated successfully');
            notifyListeners();
            return; // Successfully updated
          } catch (e) {
            print('Error updating Firestore: $e');
            throw Exception('Failed to update Firestore: $e');
          }
        } else {
          print('Ingredient not found in the recipe');
          throw Exception('Ingredient not found in the recipe');
        }
      } else {
        print('Recipe is null');
        throw Exception('Recipe is null');
      }
    } else {
      print('Recipe not found in _userRecipes');
      throw Exception('Recipe not found');
    }
  }

  Future<void> addRecipe(Recipe recipe, String userId) async {
    recipe.dateAdded = DateTime.now();
    for (var ingredient in recipe.extendedIngredients ?? []) {
      await ingredient.convertToGrams(_conversionService);
    }
    _userRecipes[recipe.id.toString()] = recipe;

    await FirestoreServices.saveUserRecipe(
        userId, recipe.id.toString(), recipe);

    notifyListeners();
  }

  void removeIngredient(String userId, String recipeId,
      ExtendedIngredient ingredient, String recipeTitle) {
    if (_userRecipes.containsKey(recipeId)) {
      final recipe = _userRecipes[recipeId];
      recipe?.extendedIngredients
          ?.removeWhere((i) => i.uniqueId == ingredient.uniqueId);
      FirestoreServices.saveUserRecipe(userId, recipeId, recipe!);

      // Add to removed ingredients history
      _recentlyRemovedIngredients.add(RemovedIngredient(
        ingredient: ingredient,
        recipeId: recipeId,
        recipeTitle: recipeTitle,
        dateRemoved: DateTime.now(),
      ));

      saveDeleteHistory(userId);
      notifyListeners();
    }
  }

  void clearRecipe(String userId, String recipeId) {
    if (_userRecipes.containsKey(recipeId)) {
      final deletedRecipe = _userRecipes.remove(recipeId);
      if (deletedRecipe != null) {
        deletedRecipe.dateRemoved = DateTime.now();
        _recentlyDeletedRecipes.add(deletedRecipe);
        FirestoreServices.removeUserRecipe(userId, recipeId);
        saveDeleteHistory(userId);
        notifyListeners();
      }
    }
  }

  void clearAllDeletedRecipes(String userId) {
    _recentlyDeletedRecipes.clear();
    FirestoreServices.clearAllDeletedRecipes(userId);
    notifyListeners();
  }

  void clearAllRemovedIngredients(String userId) {
    _recentlyRemovedIngredients.clear();
    notifyListeners();
  }

  Future<void> restoreRecipe(String userId, Recipe recipe) async {
    // Remove from deleted recipes
    _recentlyDeletedRecipes.removeWhere((r) => r.id == recipe.id);

    // Add back to user recipes
    recipe.dateAdded = DateTime.now(); // Update the date added
    recipe.dateRemoved = null; // Clear the date removed
    _userRecipes[recipe.id.toString()] = recipe;

    // Update Firestore
    FirestoreServices.saveUserRecipe(userId, recipe.id.toString(), recipe);
    FirestoreServices.removeFromDeletedRecipes(userId, recipe.id.toString());
    await saveDeleteHistory(userId);
    notifyListeners();
  }

  Future<void> restoreIngredient(
      String userId, RemovedIngredient removedIngredient) async {
    if (_userRecipes.containsKey(removedIngredient.recipeId)) {
      final recipe = _userRecipes[removedIngredient.recipeId];
      recipe?.extendedIngredients?.add(removedIngredient.ingredient);
      FirestoreServices.saveUserRecipe(
          userId, removedIngredient.recipeId, recipe!);
      _recentlyRemovedIngredients.remove(removedIngredient);
      await saveDeleteHistory(userId);
      notifyListeners();
    }
  }

  //Shopping List Section
  ExtendedIngredient? findIngredientById(String ingredientId) {
    for (var recipe in _userRecipes.values) {
      for (var ingredient in recipe.extendedIngredients ?? []) {
        if (ingredient.uniqueId == ingredientId) {
          return ingredient;
        }
      }
    }
    return null;
  }

  Future<void> addToShoppingList(String userId, ShoppingListItem item) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('shopping_list')
          .doc(item.id)
          .set(item.toJson());
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding item to shopping list: $e');
      }
      throw Exception('Failed to add item to shopping list');
    }
  }

  List<Recipe> getRecentlyDeletedRecipes() {
    return _recentlyDeletedRecipes;
  }

  List<RemovedIngredient> getRecentlyRemovedIngredients() {
    return _recentlyRemovedIngredients;
  }

  Future<void> loadDeleteHistory(String userId) async {
    _recentlyRemovedIngredients.clear();
    _recentlyDeletedRecipes.clear();

    final history = await FirestoreServices.loadDeleteHistory(userId);

    if (history.containsKey('removedIngredients')) {
      _recentlyRemovedIngredients.addAll(
        (history['removedIngredients'] as List)
            .map((json) => RemovedIngredient.fromJson(json))
            .toList(),
      );
    }

    if (history.containsKey('deletedRecipes')) {
      _recentlyDeletedRecipes.addAll(
        (history['deletedRecipes'] as List)
            .map((json) => Recipe.fromJson(json))
            .toList(),
      );
    }

    notifyListeners();
  }

  Future<void> saveDeleteHistory(String userId) async {
    await FirestoreServices.saveDeleteHistory(
      userId,
      _recentlyRemovedIngredients,
      _recentlyDeletedRecipes,
    );
  }

  Future<void> permanentlyRemoveRecipe(String userId, String recipeId) async {
    _recentlyDeletedRecipes
        .removeWhere((recipe) => recipe.id.toString() == recipeId);
    FirestoreServices.permanentlyRemoveUserRecipe(userId, recipeId);
    await saveDeleteHistory(userId);
    notifyListeners();
  }

  Future<void> permanentlyRemoveIngredient(
      String userId, String recipeId, String ingredientId) async {
    try {
      await FirestoreServices.permanentlyRemoveIngredient(
          userId, recipeId, ingredientId);
      _recentlyRemovedIngredients.removeWhere((removedIngredient) =>
          removedIngredient.recipeId == recipeId &&
          removedIngredient.ingredient.uniqueId == ingredientId);
      await saveDeleteHistory(userId);
      notifyListeners();
    } catch (e) {
      print('Error permanently removing ingredient: $e');
      // Handle the error (e.g., show an error message to the user)
    }
  }

  Future<void> undoDeleteRecipe(String userId) async {
    if (_recentlyDeletedRecipes.isNotEmpty) {
      final recipeToRestore = _recentlyDeletedRecipes.removeLast();
      _userRecipes[recipeToRestore.id.toString()] = recipeToRestore;
      await FirestoreServices.saveUserRecipe(
          userId, recipeToRestore.id.toString(), recipeToRestore);
      notifyListeners();
    }
  }

  bool get canUndo => _recentlyDeletedRecipes.isNotEmpty;

  Future<void> loadUserIngredients(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final recipesData = userDoc.data()?['recipes'] as Map<String, dynamic>?;
      if (recipesData != null) {
        recipesData.forEach((recipeId, recipeData) {
          final recipe = Recipe.fromJson(recipeData);
          _userRecipes[recipeId] = recipe;
          print("Loaded recipe: ${recipe.title}");
          recipe.extendedIngredients?.forEach((ingredient) {
            print(
                "Loaded Ingredient: ${ingredient.name} - Converted: ${ingredient.convertedAmount} ${ingredient.convertedUnit}");
          });
        });
        notifyListeners();
      }
    }
  }

  RecipeInfo? getRecipeInfo(String recipeId) {
    final recipe = _userRecipes[recipeId];
    return recipe != null ? RecipeInfo.fromRecipe(recipe) : null;
  }

  List<CategorizedIngredients> getCategorizedIngredients() {
    final categorizedMap = <String, List<ExtendedIngredient>>{};

    for (final recipe in _userRecipes.values) {
      for (final ingredient in recipe.extendedIngredients ?? []) {
        final category = ingredient.aisle ?? 'Other';
        categorizedMap.putIfAbsent(category, () => []).add(ingredient);
      }
    }

    return categorizedMap.entries
        .map((entry) => CategorizedIngredients(
              category: entry.key,
              ingredients: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.category.compareTo(b.category));
  }
}

class RecipeInfo {
  final int? id;
  final String? title;
  final String? image;
  final List<ExtendedIngredient>? extendedIngredients;

  RecipeInfo({
    required this.id,
    this.title,
    this.image,
    this.extendedIngredients,
  });

  factory RecipeInfo.fromRecipe(Recipe recipe) {
    return RecipeInfo(
      id: recipe.id,
      title: recipe.title,
      image: recipe.image,
      extendedIngredients: recipe.extendedIngredients,
    );
  }
}
