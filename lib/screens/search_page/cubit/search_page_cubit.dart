import 'package:bloc/bloc.dart';
import 'package:food_recipe_app/models/auto_complete.dart';
import 'package:food_recipe_app/repo/get_recipe_by_ingredients.dart';
import 'package:food_recipe_app/screens/search_page/cubit/search_page_state.dart';

class SearchPageCubit extends Cubit<SearchPageState> {
  SearchPageCubit(this._recipeRepository) : super(SearchPageState.initial());

  final RecipeRepository _recipeRepository;

  void toggleAdvancedSearch() {
    emit(state.copyWith(
      isAdvancedSearchEnabled: !state.isAdvancedSearchEnabled,
      searchList: [],
      ingredients: [],
      searchText: '',
    ));
  }

  void textChange(String text) {
    if (state.isAdvancedSearchEnabled) {
      final ingredients = text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      emit(state.copyWith(
        searchText: text,
        ingredients: ingredients,
      ));
      _performAdvancedSearch(ingredients);
    } else {
      emit(state.copyWith(searchText: text));
      _performRegularSearch(text);
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
      final searchList = recipes
          .map((recipe) => SearchAutoComplete(
                id: recipe.id.toString(),
                name: recipe.title ?? 'Unknown Recipe',
                image: recipe.image ?? '',
              ))
          .toList();
      emit(state.copyWith(status: Status.success, searchList: searchList));
    } catch (e) {
      emit(state.copyWith(status: Status.failure));
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
}
