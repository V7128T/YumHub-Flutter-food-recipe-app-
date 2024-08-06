import 'package:food_recipe_app/models/shopping_list_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:food_recipe_app/models/store_recipe.dart';
import 'package:food_recipe_app/models/store_product.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:3000';

  Future<List<Recipe>> getRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/recipes'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Recipe.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Product.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> addToShoppingList(ShoppingListItem item) async {
    bool productExists = await doesProductExist(item.name);
    if (productExists) {
      final response = await http.post(
        Uri.parse('$baseUrl/shopping_list'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to add item to shopping list');
      }
    } else {
      List<Product> similarProducts = await findSimilarProducts(item.name);
      if (similarProducts.isNotEmpty) {
        // Here you would typically show these options to the user
        // For demonstration, let's just add the first similar product
        final similarItem = ShoppingListItem(
          id: item.id,
          name: similarProducts[0].name,
          amount: item.amount,
          unit: item.unit,
          recipeId: item.recipeId,
          recipeName: item.recipeName,
          added: item.added,
        );
        final response = await http.post(
          Uri.parse('$baseUrl/shopping_list'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(similarItem.toJson()),
        );
        if (response.statusCode != 201) {
          throw Exception('Failed to add similar item to shopping list');
        }
      } else {
        throw Exception('No similar products found for ${item.name}');
      }
    }
  }

  Future<List<ShoppingListItem>> getShoppingList() async {
    final response = await http.get(Uri.parse('$baseUrl/shopping_list'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((item) => ShoppingListItem.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load shopping list');
    }
  }

  Future<bool> doesProductExist(String ingredientName) async {
    final response =
        await http.get(Uri.parse('$baseUrl/products?name=$ingredientName'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.isNotEmpty;
    } else {
      throw Exception('Failed to check product existence');
    }
  }

  Future<List<Product>> findSimilarProducts(String ingredientName) async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<Product> allProducts =
          jsonResponse.map((item) => Product.fromJson(item)).toList();

      // Simple similarity check based on substring
      return allProducts
          .where((product) =>
              product.name
                  .toLowerCase()
                  .contains(ingredientName.toLowerCase()) ||
              ingredientName.toLowerCase().contains(product.name.toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
