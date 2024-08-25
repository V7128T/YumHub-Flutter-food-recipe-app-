import 'package:bloc/bloc.dart';
import 'package:food_recipe_app/models/failure.dart';
import 'package:food_recipe_app/models/recipe.dart';
import '../../../models/equipment.dart';
import '../../../models/nutrients.dart';
import '../../../models/similar_list.dart';
import '../../../repo/get_recipe_info.dart';
part 'recipe_info_event.dart';
part 'recipe_info_state.dart';

class RecipeInfoBloc extends Bloc<RecipeInfoEvent, RecipeInfoState> {
  final GetRecipeInfo repo = GetRecipeInfo();

  RecipeInfoBloc() : super(RecipeInfoInitial()) {
    on<RecipeInfoEvent>((event, emit) async {
      if (event is LoadRecipeInfo) {
        try {
          emit(RecipeInfoLoadState());
          final data = await repo.getRecipeInfo(event.id);

          // Check if data contains the expected number of elements
          if (data.length >= 4) {
            emit(
              RecipeInfoSuccesState(
                recipe: data[0],
                nutrient: data[3],
                similar: data[1].list,
                equipment: data[2].items,
              ),
            );
          } else {
            throw Failure(
                code: 500, message: 'Incomplete data received from API');
          }
        } catch (e) {
          print('Error in RecipeInfoBloc: $e'); // Debugging log
          if (e is Failure) {
            emit(RecipeInfoErrorState(
              errorMessage: e.message,
              errorCode: e.code,
            ));
          } else {
            emit(RecipeInfoErrorState(
              errorMessage: e.toString(),
              errorCode: 500,
            ));
          }
        }
      }
    });
  }
}
