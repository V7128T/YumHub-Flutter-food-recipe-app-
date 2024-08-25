import 'package:bloc/bloc.dart';
import 'package:food_recipe_app/models/auto_complete.dart';
import 'package:food_recipe_app/repo/get_recipe_by_ingredients.dart';
import 'package:food_recipe_app/screens/search_page/cubit/search_page_state.dart';
import '../../../services/getRecipeVideos.dart';

class SearchPageCubit extends Cubit<SearchPageState> {
  SearchPageCubit(this._recipeRepository) : super(SearchPageState.initial());

  final RecipeRepository _recipeRepository;
  final GetRecipeVideos _getRecipeVideos = GetRecipeVideos();

  Future<void> fetchRecipeVideos(String recipeTitle) async {
    try {
      final videos = await _getRecipeVideos.fetchRecipeVideos(recipeTitle);
      emit(state.copyWith(videos: videos));
    } catch (e) {
      emit(state.copyWith(status: Status.failure));
    }
  }

  void toggleAdvancedSearch() {
    emit(state.copyWith(
      isAdvancedSearchEnabled: !state.isAdvancedSearchEnabled,
      isVideoSearchEnabled: false,
      searchList: [],
      ingredients: [],
      searchText: '',
    ));
  }

  void textChange(String text) {
    emit(state.copyWith(searchText: text));
    if (state.isAdvancedSearchEnabled) {
      final ingredients = text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      emit(state.copyWith(ingredients: ingredients));
      _performAdvancedSearch(ingredients);
    } else if (state.isVideoSearchEnabled) {
      _performVideoSearch(text);
    } else {
      emit(state.copyWith(searchText: text));
      _performRegularSearch(text);
    }
  }

  void submitSearch() {
    if (state.isAdvancedSearchEnabled) {
      _performAdvancedSearch(state.ingredients);
    } else if (state.isVideoSearchEnabled) {
      _performVideoSearch(state.searchText);
    } else {
      _performRegularSearch(state.searchText);
    }
  }

  Future<void> _performRegularSearch(String text) async {
    if (text.isEmpty) {
      emit(state.copyWith(searchList: [], status: Status.initial));
      return;
    }
    emit(state.copyWith(status: Status.loading));
    try {
      final list = await _recipeRepository.getAutoCompleteList(text);
      emit(state.copyWith(searchList: list.list, status: Status.success));
    } catch (e) {
      emit(state.copyWith(status: Status.failure));
    }
  }

  void updateIngredientsAndSearch(List<String> ingredients) {
    emit(state.copyWith(
      ingredients: ingredients,
      searchText: ingredients.join(', '),
    ));
    _performAdvancedSearch(ingredients);
  }

  Future<void> _performAdvancedSearch(List<String> ingredients) async {
    if (ingredients.isEmpty) {
      emit(state.copyWith(searchList: [], status: Status.initial));
      return;
    }
    emit(state.copyWith(status: Status.loading));
    try {
      final recipes = await _recipeRepository.searchByIngredients(ingredients);

      // Sort recipes based on how many of the specified ingredients they contain
      recipes.sort((a, b) {
        int aCount = a.extendedIngredients
                ?.where((ing) => ingredients.any((i) =>
                    ing.name?.toLowerCase().contains(i.toLowerCase()) ?? false))
                .length ??
            0;
        int bCount = b.extendedIngredients
                ?.where((ing) => ingredients.any((i) =>
                    ing.name?.toLowerCase().contains(i.toLowerCase()) ?? false))
                .length ??
            0;
        return bCount.compareTo(aCount);
      });

      final searchList = recipes
          .map((recipe) => SearchAutoComplete(
                id: recipe.id.toString(),
                name: recipe.title ?? 'Unknown Recipe',
                image: recipe.image ?? '',
              ))
          .toList();

      if (searchList.isEmpty) {
        emit(state.copyWith(
            status: Status.success,
            searchList: [],
            message: "No recipes found with these ingredients."));
      } else {
        emit(state.copyWith(status: Status.success, searchList: searchList));
      }
    } catch (e) {
      emit(state.copyWith(
          status: Status.failure,
          message: "Failed to search recipes. Please try again."));
    }
  }

  void removeIngredient(String ingredient) {
    final updatedIngredients = List<String>.from(state.ingredients)
      ..remove(ingredient);
    final updatedSearchText = updatedIngredients.join(', ');
    emit(state.copyWith(
      ingredients: updatedIngredients,
      searchText: updatedSearchText,
    ));
    if (updatedIngredients.isNotEmpty) {
      _performAdvancedSearch(updatedIngredients);
    } else {
      emit(state.copyWith(searchList: [], status: Status.initial));
    }
  }

  void toggleVideoSearch() {
    emit(state.copyWith(
      isVideoSearchEnabled: !state.isVideoSearchEnabled,
      isAdvancedSearchEnabled: false,
      searchList: [],
      ingredients: [],
      videos: [],
      searchText: '',
    ));
  }

  void resetSearch() {
    emit(state.copyWith(
      isAdvancedSearchEnabled: false,
      isVideoSearchEnabled: false,
      searchList: [],
      ingredients: [],
      videos: [],
      searchText: '',
    ));
  }

  void videoTextChange(String text) {
    emit(state.copyWith(searchText: text));
    _performVideoSearch(text);
  }

  Future<void> _performVideoSearch(String text) async {
    if (text.isEmpty) {
      emit(state.copyWith(videos: [], status: Status.initial));
      return;
    }
    emit(state.copyWith(status: Status.loading));
    try {
      final videos = await _getRecipeVideos.fetchRecipeVideos(text);
      if (videos.isEmpty) {
        emit(state.copyWith(
            videos: [],
            status: Status.success,
            message: "No videos found for this search."));
      } else {
        emit(state.copyWith(videos: videos, status: Status.success));
      }
    } catch (e) {
      emit(state.copyWith(
          status: Status.failure,
          message: "Failed to search videos. Please try again."));
    }
  }
}
