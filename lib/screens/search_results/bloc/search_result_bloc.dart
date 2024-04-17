import 'package:bloc/bloc.dart';
import 'package:food_recipe_app/models/failure.dart';
import 'package:food_recipe_app/repo/get_search_results.dart';
import 'package:food_recipe_app/screens/search_results/bloc/search_result_event.dart';
import 'package:food_recipe_app/screens/search_results/bloc/search_result_state.dart';


class SearchResultsBloc extends Bloc<SearchResultsEvent, SearchResultsState> {
  final repo = SearchRepo();
  SearchResultsBloc() : super(SearchResultsInitial()) {
    on<SearchResultsEvent>((event, emit) async {
      if (event is LoadSearchResults) {
        try {
          emit(SearchResultsLoading());
          final results = await repo.getSearchList(event.name, 100);
          ///Emitting Search Success Result
          emit(SearchResultsSuccess(
            results: results.list,
          ));
        } on Failure catch (e) {
          emit(HomeFailureState(error: e));
        } catch (e) {
          print(e.toString());
          emit(SearchResultsError());
        }
      }
    });
  }
}