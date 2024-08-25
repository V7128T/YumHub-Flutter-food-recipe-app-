import 'package:equatable/equatable.dart';
import 'package:food_recipe_app/models/auto_complete.dart';
import 'package:food_recipe_app/models/recipe.dart';

///Search Page States
enum Status { loading, initial, success, failure }

enum SearchMode { regular, ingredients, videos }

class SearchPageState extends Equatable {
  final Status status;
  final String searchText;
  final List<Recipe> recipeList;
  final bool isAdvancedSearchEnabled;
  final bool isVideoSearchEnabled;
  final List<SearchAutoComplete> searchList;
  final List<String> ingredients;
  final List<RecipeVideo> videos;
  final String? message;

  const SearchPageState({
    required this.status,
    required this.searchText,
    required this.searchList,
    required this.recipeList,
    this.isAdvancedSearchEnabled = false,
    this.isVideoSearchEnabled = false,
    this.ingredients = const [],
    this.videos = const [],
    this.message,
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
        isVideoSearchEnabled,
        ingredients,
        videos,
      ];

  SearchPageState copyWith({
    Status? status,
    String? searchText,
    String? searchValue,
    List<SearchAutoComplete>? searchList,
    bool? isAdvancedSearchEnabled,
    bool? isVideoSearchEnabled,
    List<Recipe>? recipeList,
    List<String>? ingredients,
    List<RecipeVideo>? videos,
    String? message,
  }) {
    return SearchPageState(
      status: status ?? this.status,
      searchText: searchText ?? this.searchText,
      searchList: searchList ?? this.searchList,
      recipeList: recipeList ?? this.recipeList,
      isAdvancedSearchEnabled:
          isAdvancedSearchEnabled ?? this.isAdvancedSearchEnabled,
      isVideoSearchEnabled: isVideoSearchEnabled ?? this.isVideoSearchEnabled,
      ingredients: ingredients ?? this.ingredients,
      videos: videos ?? this.videos,
      message: message ?? this.message,
    );
  }
}
