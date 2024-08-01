import 'package:equatable/equatable.dart';
import 'package:food_recipe_app/models/auto_complete.dart';
import 'package:food_recipe_app/models/recipe.dart';

///Search Page States
enum Status { loading, initial, success, failure }

class SearchPageState extends Equatable {
  final Status status;
  final String searchText;
  final List<Recipe> recipeList;
  final bool isAdvancedSearchEnabled;
  final List<SearchAutoComplete> searchList;
  final List<String> ingredients;

  const SearchPageState({
    required this.status,
    required this.searchText,
    required this.searchList,
    required this.recipeList,
    this.isAdvancedSearchEnabled = false,
    this.ingredients = const [],
  });

  factory SearchPageState.initial() {
    return const SearchPageState(
      status: Status.initial,
      searchText: '',
      searchList: [],
      recipeList: [],
    );
  }

  @override
  List<Object> get props => [
        status,
        searchText,
        searchList,
        recipeList,
        isAdvancedSearchEnabled,
        ingredients
      ];

  SearchPageState copyWith({
    Status? status,
    String? searchText,
    String? searchValue,
    List<SearchAutoComplete>? searchList,
    bool? isAdvancedSearchEnabled,
    List<Recipe>? recipeList,
    List<String>? ingredients,
  }) {
    return SearchPageState(
      status: status ?? this.status,
      searchText: searchText ?? this.searchText,
      searchList: searchList ?? this.searchList,
      recipeList: recipeList ?? this.recipeList,
      isAdvancedSearchEnabled:
          isAdvancedSearchEnabled ?? this.isAdvancedSearchEnabled,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}
