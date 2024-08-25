import 'package:bloc/bloc.dart';
import 'package:food_recipe_app/models/failure.dart';
import 'package:food_recipe_app/repo/get_search_results.dart';
import 'package:food_recipe_app/screens/search_results/bloc/search_result_event.dart';
import 'package:food_recipe_app/screens/search_results/bloc/search_result_state.dart';
import '../../../models/search_results.dart';
import '../../../services/getRecipeVideos.dart';
import '../../search_page/cubit/search_page_state.dart';

class SearchResultsBloc extends Bloc<SearchResultsEvent, SearchResultsState> {
  final repo = SearchRepo();
  final getRecipeVideos = GetRecipeVideos();

  SearchResultsBloc() : super(SearchResultsInitial()) {
    on<SearchResultsEvent>((event, emit) async {
      if (event is LoadSearchResults) {
        try {
          emit(SearchResultsLoading());

          if (event.mode == SearchMode.videos) {
            final videos = await getRecipeVideos.fetchRecipeVideos(event.name);
            final results = videos
                .map((video) => SearchResult(
                      id: video.youTubeId,
                      name: video.title,
                      image: video.thumbnail,
                      youTubeId: video.youTubeId,
                      views: video.views,
                      rating: video.rating,
                    ))
                .toList();

            if (results.isEmpty) {
              emit(SearchResultsEmpty());
            } else {
              emit(SearchResultsSuccess(results: results));
            }
          } else {
            final results = await repo.getSearchList(event.name, 100);
            if (results.list.isEmpty) {
              emit(SearchResultsEmpty());
            } else {
              emit(SearchResultsSuccess(results: results.list));
            }
          }
        } on Failure catch (e) {
          emit(HomeFailureState(error: e));
        } catch (e) {
          print(e.toString());
          emit(SearchResultsError(e.toString()));
        }
      }
    });
  }
}
