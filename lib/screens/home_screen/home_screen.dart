import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/animation/animation.dart';
import 'package:food_recipe_app/custom_colors/app_colors.dart';
import 'package:food_recipe_app/models/food_type.dart';
import 'package:food_recipe_app/screens/home_screen/bloc/homerecipe_bloc.dart';
import 'package:food_recipe_app/screens/home_screen/bloc/homerecipe_event.dart';
import 'package:food_recipe_app/screens/home_screen/bloc/homerecipe_state.dart';
import 'package:food_recipe_app/screens/home_screen/widgets/food_type_widget.dart';
import 'package:food_recipe_app/screens/home_screen/widgets/horizontal_list.dart';
import 'package:food_recipe_app/screens/home_screen/widgets/list_items.dart';
import 'package:food_recipe_app/screens/search_results/bloc/search_result_bloc.dart';
import 'package:food_recipe_app/screens/search_results/search_result_screen.dart';
import 'package:food_recipe_app/widgets/loading_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../custom_dialogs/error_widget.dart';
import '../search_page/cubit/search_page_state.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeRecipeScreen extends StatefulWidget {
  const HomeRecipeScreen({super.key});

  @override
  State<HomeRecipeScreen> createState() => _HomeRecipeScreenState();
}

class _HomeRecipeScreenState extends State<HomeRecipeScreen> {
  late final HomeRecipesBloc bloc;
  @override
  void initState() {
    bloc = BlocProvider.of<HomeRecipesBloc>(context);
    bloc.add(LoadHomeRecipe());
    // initDynamicLinks(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[50]!, Colors.orange[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          title: Text(
            "YumHub",
            style: GoogleFonts.playfairDisplay(
              textStyle: const TextStyle(
                fontSize: 28.0,
                color: AppColors.secFont,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.orange[50]!, Colors.orange[100]!],
            ),
          ),
          child: BlocBuilder<HomeRecipesBloc, HomeRecipesState>(
            builder: (context, state) {
              if (state is HomeRecipesLoading) {
                return const Center(child: LoadingWidget());
              } else if (state is HomeRecipesSuccess) {
                ///Display Home Screen Recipes
                return HomeScreenWidget(
                  breakfast: state.breakfast,
                  cake: state.cake,
                  drinks: state.drinks,
                  burgers: state.burgers,
                  lunch: state.lunch,
                  pizza: state.pizza,
                  rice: state.rice,
                );
              } else if (state is HomeRecipesError) {
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
      ),
    );
  }
}

class HomeScreenWidget extends StatefulWidget {
  final List<FoodType> breakfast;
  final List<FoodType> lunch;
  final List<FoodType> drinks;
  final List<FoodType> burgers;
  final List<FoodType> pizza;
  final List<FoodType> cake;
  final List<FoodType> rice;
  const HomeScreenWidget({
    super.key,
    required this.breakfast,
    required this.lunch,
    required this.drinks,
    required this.burgers,
    required this.pizza,
    required this.cake,
    required this.rice,
  });

  @override
  _HomeScreenWidgetState createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: DelayedDisplay(
            delay: const Duration(microseconds: 600),
            child: Text(
              "Simplest Way to Find \nTasty Food",
              style: GoogleFonts.playfairDisplay(
                textStyle: const TextStyle(
                  fontSize: 25.0,
                  color: AppColors.primFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const HorizontalList(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: header("Popular Breakfast Recipes", "breakfast"),
        ),
        const SizedBox(height: 2),
        DelayedDisplay(
          delay: const Duration(microseconds: 600),
          child: FoodTypeWidget(
            items: widget.breakfast,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header("Recommended Lunch Recipes", "lunch"),
              ...widget.lunch.map((meal) {
                return ListItem(
                  meal: meal,
                );
              }),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: header("Popular Drinks", "drinks"),
        ),
        const SizedBox(height: 10),
        FoodTypeWidget(items: widget.drinks),
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header("Burgers", "burgers"),
              ...widget.burgers.map((meal) {
                return ListItem(
                  meal: meal,
                );
              }).toList(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: header("Pizzas", "pizza"),
        ),
        const SizedBox(height: 10),
        FoodTypeWidget(items: widget.pizza),
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header("Best Cake Recipes", "cake"),
              ...widget.cake.map((meal) {
                return ListItem(
                  meal: meal,
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  header(String name, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DelayedDisplay(
            delay: const Duration(microseconds: 600),
            child: Row(
              // Wrap multiple widgets in a Row
              children: [
                Container(
                  width: 5,
                  height: 25,
                  color: AppColors.secFont,
                ),
                const SizedBox(width: 10),
                Text(
                  name,
                  style: GoogleFonts.playfairDisplay(
                    textStyle: const TextStyle(
                      fontSize: 20.0,
                      color: AppColors.secFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => SearchResultsBloc(),
                      child: SearchResults(
                        id: title,
                        searchMode: SearchMode.regular,
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward_sharp),
              color: AppColors.secFont)
        ],
      ),
    );
  }
}
