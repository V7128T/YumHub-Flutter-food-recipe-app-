import 'package:dio/dio.dart';
import 'package:food_recipe_app/api/api_keys.dart';
import 'package:food_recipe_app/models/auto_complete.dart';
import 'package:food_recipe_app/models/failure.dart';
import 'package:food_recipe_app/models/recipe.dart';

class RecipeRepository {
  var key = ApiKey.keys;

  Future<List<Recipe>> searchByIngredients(
    List<String> ingredients, {
    int number = 10,
    int ranking = 1,
    bool ignorePantry = true,
  }) async {
    final ingredientsStr = ingredients.join(',');
    final url =
        'https://api.spoonacular.com/recipes/findByIngredients?ingredients=$ingredientsStr&number=$number&ranking=$ranking&ignorePantry=$ignorePantry&apiKey=$key';

    try {
      final response = await Dio().get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Recipe.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Failure(code: 401, message: response.data['message']);
      } else {
        throw Failure(
            code: response.statusCode!, message: response.statusMessage!);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<SearchAutoCompleteList> getAutoCompleteList(String searchText) async {
    final url =
        'https://api.spoonacular.com/recipes/autocomplete?number=100&query=$searchText&apiKey=$key';

    try {
      final response = await Dio().get(url);

      if (response.statusCode == 200) {
        return SearchAutoCompleteList.fromJson(response.data);
      } else if (response.statusCode == 401) {
        throw Failure(code: 401, message: response.data['message']);
      } else {
        throw Failure(
            code: response.statusCode!, message: response.statusMessage!);
      }
    } catch (e) {
      rethrow;
    }
  }
}
