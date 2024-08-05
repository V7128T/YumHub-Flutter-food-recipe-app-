import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';
import 'package:food_recipe_app/models/categorized_ingredients.dart';
import 'package:food_recipe_app/auth_methods/firebaseFunctions.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:food_recipe_app/services/conversion_service.dart';

class UserIngredientList extends ChangeNotifier {
  final Map<String, Recipe> _userRecipes = {};
  final List<Recipe> _recentlyDeletedRecipes = [];
  final ConversionService _conversionService = ConversionService();

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
          await _convertIngredient(ingredient);
        }
      }
    }
    notifyListeners();
  }

  Future<void> _convertIngredient(ExtendedIngredient ingredient) async {
    if (ingredient.amount != null && ingredient.unit != null) {
      try {
        final result = await _conversionService.convertAmount(
          ingredientName: ingredient.name ?? '',
          sourceAmount: ingredient.amount!,
          sourceUnit: ingredient.unit!,
          targetUnit: 'grams',
        );

        ingredient.convertedAmount = result['targetAmount'];
        ingredient.convertedUnit = result['targetUnit'];
      } catch (e) {
        print('Error converting ingredient ${ingredient.name}: $e');
      }
    }
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
          ingredients[index] = updatedIngredient;
          recipe.extendedIngredients = ingredients;
          _userRecipes[recipeId] = recipe;

          await convertIngredients();
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
    _userRecipes[recipe.id.toString()] = recipe;
    print("Adding recipe: ${recipe.title}");
    print(
        "Recipe ingredients before saving: ${recipe.extendedIngredients?.map((e) => '${e.name}: ${e.convertedAmount} ${e.convertedUnit}').join(', ')}");

    await FirestoreServices.saveUserRecipe(
        userId, recipe.id.toString(), recipe);

    // Fetch the saved recipe from Firestore to verify the data
    final savedRecipe =
        await FirestoreServices.getRecipe(userId, recipe.id.toString());
    print(
        "Recipe ingredients after saving: ${savedRecipe.extendedIngredients?.map((e) => '${e.name}: ${e.convertedAmount} ${e.convertedUnit}').join(', ')}");

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
        deletedRecipe.dateRemoved = DateTime.now();
        _recentlyDeletedRecipes.add(deletedRecipe);
        FirestoreServices.removeUserRecipe(userId, recipeId);
        notifyListeners();
      }
    }
  }

  void clearAllDeletedRecipes(String userId) {
    _recentlyDeletedRecipes.clear();
    FirestoreServices.clearAllDeletedRecipes(userId);
    notifyListeners();
  }

  void restoreRecipe(String userId, Recipe recipe) {
    // Remove from deleted recipes
    _recentlyDeletedRecipes.removeWhere((r) => r.id == recipe.id);

    // Add back to user recipes
    recipe.dateAdded = DateTime.now(); // Update the date added
    recipe.dateRemoved = null; // Clear the date removed
    _userRecipes[recipe.id.toString()] = recipe;

    // Update Firestore
    FirestoreServices.saveUserRecipe(userId, recipe.id.toString(), recipe);
    FirestoreServices.removeFromDeletedRecipes(userId, recipe.id.toString());

    notifyListeners();
  }

  List<Recipe> getRecentlyDeletedRecipes() {
    return _recentlyDeletedRecipes;
  }

  void permanentlyRemoveRecipe(String userId, String recipeId) {
    _recentlyDeletedRecipes
        .removeWhere((recipe) => recipe.id.toString() == recipeId);
    FirestoreServices.permanentlyRemoveUserRecipe(userId, recipeId);
    notifyListeners();
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
        await convertIngredients();
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
