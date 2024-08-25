import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/widgets/loading_widget.dart';
import '../../custom_dialogs/error_widget.dart';
import '../random_recipe/widgets/recipe_info_success_widget.dart';
import 'bloc/recipe_info_bloc.dart';

class RecipeInfo extends StatefulWidget {
  final String id;
  const RecipeInfo({super.key, required this.id});

  @override
  State<RecipeInfo> createState() => _RecipeInfoState();
}

class _RecipeInfoState extends State<RecipeInfo> {
  late final RecipeInfoBloc bloc;
  @override
  void initState() {
    bloc = BlocProvider.of<RecipeInfoBloc>(context);
    bloc.add(LoadRecipeInfo(widget.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<RecipeInfoBloc, RecipeInfoState>(
          builder: (context, state) {
            if (state is RecipeInfoLoadState) {
              return const Center(child: LoadingWidget());
            } else if (state is RecipeInfoSuccesState) {
              ///Displaying Recipe Info Widget
              return RecipeInfoWidget(
                equipment: state.equipment,
                info: state.recipe,
                nutrient: state.nutrient,
                similarlist: state.similar,
                recipeId: state.recipe.id.toString(),
              );
            } else if (state is RecipeInfoErrorState) {
              return ErrorDisplay(
                errorMessage: state.errorMessage.contains(
                        'DioException [bad response]: This exception was thrown because the response has a status code of 402 and RequestOptions.validateStatus was configured to throw for this status code.')
                    ? "You've reached the daily limit of 150 API calls. Please try again tomorrow or upgrade your plan."
                    : state.errorCode == 404
                        ? "Error 404: The requested resource could not be found."
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
