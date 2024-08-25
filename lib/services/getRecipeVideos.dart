import 'package:food_recipe_app/models/recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:food_recipe_app/api/api_keys.dart';

class GetRecipeVideos {
  final String _apiKey = ApiKey.keys;

  Future<List<RecipeVideo>> fetchRecipeVideos(String recipeTitle) async {
    final url = Uri.parse(
      'https://api.spoonacular.com/food/videos/search?query=$recipeTitle&number=5&apiKey=$_apiKey',
    );
    print('Fetching recipe videos from URL: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> videoData = data['videos'];
      return videoData.map((video) => RecipeVideo.fromJson(video)).toList();
    } else {
      throw Exception(
        'Failed to load recipe videos. Status code: ${response.statusCode}',
      );
    }
  }

  Future<Recipe> fetchRecipeDetails(int id) async {
    final url = Uri.parse(
      'https://api.spoonacular.com/recipes/$id/information?apiKey=$_apiKey',
    );
    print('Fetching recipe details from URL: $url');

    final recipeResponse = await http.get(url);

    if (recipeResponse.statusCode == 200) {
      final Map<String, dynamic> recipeData = json.decode(recipeResponse.body);

      // Fetch videos for this recipe
      final List<RecipeVideo> videos =
          await fetchRecipeVideos(recipeData['title']);

      // Add videos to the recipe data
      recipeData['videos'] = videos;

      return Recipe.fromJson(recipeData);
    } else {
      throw Exception(
        'Failed to load recipe details. Status code: ${recipeResponse.statusCode}',
      );
    }
  }
}
