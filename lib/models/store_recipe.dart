class Recipe {
  final int id;
  final String name;
  final int servings;
  final List<Ingredient> ingredients;

  Recipe(
      {required this.id,
      required this.name,
      required this.servings,
      required this.ingredients});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    var ingredientsList = json['ingredients'] as List;
    List<Ingredient> ingredients =
        ingredientsList.map((i) => Ingredient.fromJson(i)).toList();

    return Recipe(
      id: json['id'],
      name: json['name'],
      servings: json['servings'],
      ingredients: ingredients,
    );
  }
}

class Ingredient {
  final int id;
  final String name;
  final double amount;
  final String unit;

  Ingredient(
      {required this.id,
      required this.name,
      required this.amount,
      required this.unit});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
    };
  }
}
