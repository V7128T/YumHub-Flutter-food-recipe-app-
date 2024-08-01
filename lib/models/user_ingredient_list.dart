import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';
import 'package:food_recipe_app/models/categorized_ingredients.dart';
import 'package:food_recipe_app/auth_methods/firebaseFunctions.dart';
import 'package:food_recipe_app/models/recipe.dart';

class UserIngredientList extends ChangeNotifier {
  final Map<String, Recipe> _userRecipes = {};
  final List<Recipe> _recentlyDeletedRecipes = [];

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

  Future<void> updateIngredient(String userId, String recipeId,
      ExtendedIngredient updatedIngredient, String recipeTitle) async {
    if (_userRecipes.containsKey(recipeId)) {
      final recipe = _userRecipes[recipeId];
      final ingredients = recipe?.extendedIngredients?.toList() ?? [];
      final index = ingredients
          .indexWhere((i) => i.uniqueId == updatedIngredient.uniqueId);
      if (index != -1) {
        ingredients[index] = updatedIngredient;
        recipe?.extendedIngredients = ingredients;
        _userRecipes[recipeId] = recipe!;

        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'recipes.$recipeId.extendedIngredients':
              ingredients.map((i) => i.toJson()).toList(),
        });

        notifyListeners();
      }
    }
  }

  void addRecipe(Recipe recipe, String userId) {
    _userRecipes[recipe.id.toString()] = recipe;
    FirestoreServices.saveUserRecipe(userId, recipe.id.toString(), recipe);
    notifyListeners();
  }

  void removeIngredient(String userId, String recipeId,
      ExtendedIngredient ingredient, String recipeTitle) {
    if (_userRecipes.containsKey(recipeId)) {
      final recipe = _userRecipes[recipeId];
      recipe?.extendedIngredients
          ?.removeWhere((i) => i.uniqueId == ingredient.uniqueId);
      FirestoreServices.saveUserRecipe(userId, recipeId, recipe!);
      notifyListeners();
    }
  }

  void clearRecipe(String userId, String recipeId) {
    if (_userRecipes.containsKey(recipeId)) {
      final deletedRecipe = _userRecipes.remove(recipeId);
      if (deletedRecipe != null) {
        _recentlyDeletedRecipes.add(deletedRecipe);
        FirestoreServices.removeUserRecipe(userId, recipeId);
        notifyListeners();
      }
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
          print(
              "Loaded recipe: $recipeId, title: ${recipe.title}, ingredients: ${recipe.extendedIngredients?.length}");

          for (var ingredient in recipe.extendedIngredients ?? []) {
            print("Ingredient: ${ingredient.name}, Aisle: ${ingredient.aisle}");
          }
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
