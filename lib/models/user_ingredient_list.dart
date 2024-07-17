import 'package:flutter/foundation.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';

class UserIngredientList extends ChangeNotifier {
  final List<ExtendedIngredient> _ingredients = [];

  List<ExtendedIngredient> get ingredients => _ingredients;

  void addIngredients(Set<ExtendedIngredient> ingredients, String recipeId) {
    final List<ExtendedIngredient> updatedIngredients =
        ingredients.map((ingredient) {
      return ExtendedIngredient(
        id: ingredient.id,
        aisle: ingredient.aisle,
        image: ingredient.image,
        consistency: ingredient.consistency,
        name: ingredient.name,
        nameClean: ingredient.nameClean,
        original: ingredient.original,
        originalString: ingredient.originalString,
        originalName: ingredient.originalName,
        amount: ingredient.amount,
        unit: ingredient.unit,
        meta: ingredient.meta,
        metaInformation: ingredient.metaInformation,
        measures: ingredient.measures,
      );
    }).toList();

    _ingredients.addAll(updatedIngredients);
    notifyListeners();
  }

  void removeIngredient(ExtendedIngredient ingredient) {
    _ingredients.remove(ingredient);
    notifyListeners();
  }

  void clearIngredients() {
    _ingredients.clear();
    notifyListeners();
  }
}
