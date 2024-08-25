import 'package:equatable/equatable.dart';
import 'package:food_recipe_app/models/failure.dart';
import 'package:food_recipe_app/models/search_results.dart';

import '../../../models/recipe.dart';

abstract class SearchResultsState extends Equatable {
  const SearchResultsState();

  @override
  List<Object> get props => [];
}

class SearchResultsInitial extends SearchResultsState {}

class SearchResultsLoading extends SearchResultsState {}

class SearchResultsSuccess extends SearchResultsState {
  final List<SearchResult> results;
  final List<RecipeVideo>? videos;

  const SearchResultsSuccess({required this.results, this.videos});
}

class SearchResultsEmpty extends SearchResultsState {}

class SearchResultsError extends SearchResultsState {
  final String errorMessage;
  const SearchResultsError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class HomeFailureState extends SearchResultsState {
  final Failure error;

  const HomeFailureState({required this.error});
}
