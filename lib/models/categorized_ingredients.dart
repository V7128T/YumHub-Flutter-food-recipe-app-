import 'package:food_recipe_app/models/extended_ingredient.dart';

class CategorizedIngredients {
  final String category;
  final List<ExtendedIngredient> ingredients;

  CategorizedIngredients({required this.category, required this.ingredients});
}
