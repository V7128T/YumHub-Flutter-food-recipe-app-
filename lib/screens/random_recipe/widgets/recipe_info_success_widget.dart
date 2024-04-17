import 'package:flutter/material.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:food_recipe_app/screens/random_recipe/widgets/equipment.dart';
import 'package:food_recipe_app/screens/random_recipe/widgets/nutrients.dart';
import '../../../animation/animation.dart';

import '../../../models/equipment.dart';
import '../../../models/nutrients.dart';
import '../../../models/similar_list.dart';
import 'ingredients.dart';
import 'similar_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'appbar.dart';

class RacipeInfoWidget extends StatefulWidget {
  final Recipe info;
  final List<Similar> similarlist;
  final List<Equipment> equipment;
  final Nutrient nutrient;

  const RacipeInfoWidget({
    Key? key,
    required this.info,
    required this.similarlist,
    required this.equipment,
    required this.nutrient,
  }) : super(key: key);

  @override
  State<RacipeInfoWidget> createState() => _RacipeInfoWidgetState();
}

class _RacipeInfoWidgetState extends State<RacipeInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            delegate: MySliverAppBar(expandedHeight: 300, info: widget.info),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DelayedDisplay(
                    delay: const Duration(microseconds: 600),
                    child: Container(
                      padding: const EdgeInsets.all(26.0),
                      child: Text(
                        widget.info.title!,
                        style: GoogleFonts.chivo(
                          textStyle: const TextStyle(
                            fontSize: 27.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26.0, vertical: 10),
                    child: DelayedDisplay(
                      delay: const Duration(microseconds: 700),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(-2, -2),
                              blurRadius: 12,
                              color: Color.fromRGBO(0, 0, 0, 0.05),
                            ),
                            BoxShadow(
                              offset: Offset(2, 2),
                              blurRadius: 5,
                              color: Color.fromRGBO(0, 0, 0, 0.10),
                            )
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Column(
                                children: [
                                  Text(
                                    "${widget.info.readyInMinutes} Min",
                                    style: GoogleFonts.chivo(
                                      textStyle: const TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Prep. time",
                                    style: GoogleFonts.chivo(
                                      textStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 30,
                              width: 2,
                              color: Theme.of(context).primaryColor,
                            ),
                            Flexible(
                              flex: 1,
                              child: Column(
                                children: [
                                  Text(
                                    widget.info.servings.toString(),
                                    style: GoogleFonts.chivo(
                                      textStyle: const TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Servings",
                                    style: GoogleFonts.chivo(
                                      textStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 30,
                              width: 2,
                              color: Theme.of(context).primaryColor,
                            ),
                            Flexible(
                              flex: 1,
                              child: Column(
                                children: [
                                  Text(
                                    '\$${widget.info.pricePerServing}',
                                    style: GoogleFonts.chivo(
                                      textStyle: const TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Price/Servings",
                                    style: GoogleFonts.chivo(
                                      textStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(26.0),
                    child: DelayedDisplay(
                      delay: const Duration(microseconds: 700),
                      child: Text(
                        "Ingredients",
                        style: GoogleFonts.workSans(
                          textStyle: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.info.extendedIngredients!.isNotEmpty)
                    DelayedDisplay(
                      delay: const Duration(microseconds: 600),
                      child: IngredientsWidget(
                        recipe: widget.info,
                      ),
                    ),
                  if (widget.info.instructions != null)
                    Padding(
                      padding: const EdgeInsets.all(26.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Instructions",
                            style: GoogleFonts.workSans(
                              textStyle: const TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  if (widget.equipment.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(26.0),
                      child: Text(
                        "Equipments",
                        style: GoogleFonts.workSans(
                          textStyle: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  if (widget.equipment.isNotEmpty)
                    EquipmentsListView(
                      equipments: widget.equipment,
                    ),
                  if (widget.info.summary != null)
                    Padding(
                      padding: const EdgeInsets.all(26.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quick summary",
                            style: GoogleFonts.workSans(
                              textStyle: const TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  NutrientsWidgets(
                    nutrient: widget.nutrient,
                  ),
                  NutrientsbadWidget(
                    nutrient: widget.nutrient,
                  ),
                  NutrientsgoodWidget(
                    nutrient: widget.nutrient,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (widget.similarlist.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 26),
                      child: Text(
                        "Similar items",
                        style: GoogleFonts.chivo(
                          textStyle: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  if (widget.similarlist.isNotEmpty)
                    SimilarListWidget(items: widget.similarlist),
                  const SizedBox(
                    height: 40,
                  ),
                ]),
          )
        ],
      ),
    );
  }
}
