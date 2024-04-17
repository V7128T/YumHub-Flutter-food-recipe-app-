part of 'recipe_info_bloc.dart';

abstract class RecipeInfoEvent {}

class LoadRecipeInfo extends RecipeInfoEvent {
  final String id;

  LoadRecipeInfo(this.id);
}
