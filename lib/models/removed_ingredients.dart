import 'package:food_recipe_app/models/extended_ingredient.dart';

class RemovedIngredient {
  final ExtendedIngredient ingredient;
  final String recipeId;
  final String recipeTitle;
  final DateTime dateRemoved;

  RemovedIngredient({
    required this.ingredient,
    required this.recipeId,
    required this.recipeTitle,
    required this.dateRemoved,
  });

  factory RemovedIngredient.fromJson(Map<String, dynamic> json) {
    return RemovedIngredient(
      ingredient: ExtendedIngredient.fromJson(json['ingredient']),
      recipeId: json['recipeId'],
      recipeTitle: json['recipeTitle'],
      dateRemoved: DateTime.parse(json['dateRemoved']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient': ingredient.toJson(),
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
      'dateRemoved': dateRemoved.toIso8601String(),
    };
  }
}
