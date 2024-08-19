import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/animation/animation.dart';
import 'package:food_recipe_app/screens/search_results/bloc/search_result_bloc.dart';
import 'package:food_recipe_app/screens/search_results/search_result_screen.dart';

class HorizontalList extends StatelessWidget {
  const HorizontalList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Explore Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              SizedBox(width: 16),
              ChipWidget("Drinks"),
              ChipWidget("Baking"),
              ChipWidget("Desserts"),
              ChipWidget("Vegetarian"),
              ChipWidget("Sauces"),
              ChipWidget("Stir Fry"),
              ChipWidget("Seafood"),
              ChipWidget("Meat"),
              ChipWidget("Lamb"),
              ChipWidget("Pork"),
              ChipWidget("Poultry"),
              ChipWidget("Duck"),
              ChipWidget("Turkey"),
              ChipWidget("Chicken"),
              ChipWidget("Sausages"),
              ChipWidget("Mince"),
              ChipWidget("Burgers"),
              ChipWidget("Pies"),
              ChipWidget("Pasta"),
              ChipWidget("Noodles"),
              ChipWidget("Rice"),
              ChipWidget("Pizza"),
              ChipWidget("Sides"),
              ChipWidget("Salads"),
              ChipWidget("Soups"),
              ChipWidget("Snacks"),
            ],
          ),
        ),
      ],
    );
  }
}

class ChipWidget extends StatelessWidget {
  final String text;
  const ChipWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: DelayedDisplay(
        delay: const Duration(microseconds: 600),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => SearchResultsBloc(),
                    child: SearchResults(
                      id: text,
                    ),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
