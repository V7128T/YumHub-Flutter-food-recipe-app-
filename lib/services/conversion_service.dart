import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:food_recipe_app/api/api_keys.dart';

class ConversionService {
  var key = ApiKey.keys;
  final String baseUrl = 'https://api.spoonacular.com/recipes/convert';

  Future<Map<String, dynamic>> convertAmount({
    required String ingredientName,
    required double sourceAmount,
    required String sourceUnit,
    required String targetUnit,
  }) async {
    print(
        "ConversionService: Attempting to convert $sourceAmount $sourceUnit of $ingredientName to $targetUnit");

    final response = await http.get(
      Uri.parse(
          '$baseUrl?apiKey=$key&ingredientName=$ingredientName&sourceAmount=$sourceAmount&sourceUnit=$sourceUnit&targetUnit=$targetUnit'),
    );

    print("API Response Status Code: ${response.statusCode}");
    print("API Response: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print("Parsed JSON: $jsonResponse");
      return jsonResponse;
    } else {
      print("API Error: ${response.reasonPhrase}");
      throw Exception('Failed to convert amount: ${response.statusCode}');
    }
  }
}
