import 'package:dio/dio.dart';
import 'package:food_recipe_app/api/api_keys.dart';
import 'package:food_recipe_app/models/auto_complete.dart';
import 'package:food_recipe_app/models/failure.dart';
import 'package:food_recipe_app/models/search_results.dart';

class SearchRepo {
  var key = ApiKey.keys;

  ///Network Calling to get searched query from Spoonacular api
  Future<SearchResultList> getSearchList(String type, int no) async {
    var url =
        'https://api.spoonacular.com/recipes/complexSearch?query=$type&number=$no&apiKey=${key}';

    var response = await Dio().get(url);

    if (response.statusCode == 200) {
      return SearchResultList.fromJson(response.data['results']);
    } else if (response.statusCode == 401) {
      throw Failure(code: 401, message: response.data['message']);
    } else {
      throw Failure(
          code: response.statusCode!, message: response.statusMessage!);
    }
  }

  ///Network Call for auto complete search
  ///Same as returning a search delegate in flutter
  Future<SearchAutoCompleteList> getAutoCompleteList(String searchText) async {
    var url =
        'https://api.spoonacular.com/recipes/autocomplete?number=100&query=$searchText&apiKey=${key}';
    var response = await Dio().get(url);

    if (response.statusCode == 200) {
      return SearchAutoCompleteList.fromJson(response.data);
    } else if (response.statusCode == 401) {
      throw Failure(code: 401, message: response.data['message']);
    } else {
      throw Failure(
          code: response.statusCode!, message: response.statusMessage!);
    }
  }
}
