import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/models/failure.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:food_recipe_app/repo/get_random_recipe.dart';
import '../../../models/equipment.dart';
import '../../../models/nutrients.dart';
import '../../../models/similar_list.dart';

part 'random_recipe_event.dart';
part 'random_recipe_state.dart';

class RandomRecipeBloc extends Bloc<RandomRecipeEvent, RandomRecipeState> {
  final GetRandomRecipe repo = GetRandomRecipe();
  RandomRecipeBloc() : super(RandomRecipeInitial()) {
    // ignore: void_checks
    on<RandomRecipeEvent>((event, emit) async {
      if (event is LoadRandomRecipe) {
        try {
          emit(RandomRecipeLoadState());
          final data = await repo.getRecipe();
          ///emitting Random Recipe Success to UI
          emit(
            RandomRecipeSuccesState(
              recipe: data[0],
              nutrient: data[3],
              similar: data[1].list,
              equipment: data[2].items,
            ),
          );
        } on Failure catch (e) {
          emit(FailureState(error: e));
        } catch (e) {
          print(e.toString());
          emit(RandomRecipeErrorState());
        }
      }
    });
  }
}