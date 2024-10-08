part of 'recipe_info_bloc.dart';

abstract class RecipeInfoState {}

class RecipeInfoInitial extends RecipeInfoState {}

class RecipeInfoLoadState extends RecipeInfoState {}

class RecipeInfoSuccesState extends RecipeInfoState {
  final Recipe recipe;
  final List<Similar> similar;
  final List<Equipment> equipment;
  final Nutrient nutrient;

  RecipeInfoSuccesState({
    required this.recipe,
    required this.nutrient,
    required this.similar,
    required this.equipment,
  });
}

class RecipeInfoErrorState extends RecipeInfoState {
  final String errorMessage;
  final int errorCode;

  RecipeInfoErrorState({required this.errorMessage, required this.errorCode});
}

class FailureState extends RecipeInfoState {
  final Failure error;

  FailureState({required this.error});
}
