import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/widgets/loading_widget.dart';
import '../../custom_dialogs/error_widget.dart';
import 'bloc/random_recipe_bloc.dart';
import 'widgets/recipe_info_success_widget.dart';

class RandomRecipe extends StatefulWidget {
  const RandomRecipe({super.key});

  @override
  State<RandomRecipe> createState() => _RandomRecipeState();
}

class _RandomRecipeState extends State<RandomRecipe> {
  late final RandomRecipeBloc bloc;
  @override
  void initState() {
    ///Getting RandomRecipe Bloc on re rendering UI
    bloc = BlocProvider.of<RandomRecipeBloc>(context);
    bloc.add(LoadRandomRecipe());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<RandomRecipeBloc, RandomRecipeState>(
          builder: (context, state) {
            if (state is RandomRecipeLoadState) {
              return const Center(child: LoadingWidget());
            } else if (state is RandomRecipeSuccesState) {
              ///On Success
              return RecipeInfoWidget(
                equipment: state.equipment,
                info: state.recipe,
                nutrient: state.nutrient,
                similarlist: state.similar,
                recipeId: state.recipe.id.toString(),
              );
            } else if (state is RandomRecipeErrorState) {
              return ErrorDisplay(
                errorMessage: state.errorMessage.contains(
                        'DioException [bad response]: This exception was thrown because the response has a status code of 402 and RequestOptions.validateStatus was configured to throw for this status code.')
                    ? "You've reached the daily limit of 150 API calls. Please try again tomorrow or upgrade your plan."
                    : state.errorMessage,
              );
            } else {
              return const Center(
                child: Text("Unexpected state. Please restart the app."),
              );
            }
          },
        ),
      ),
    );
  }
}
