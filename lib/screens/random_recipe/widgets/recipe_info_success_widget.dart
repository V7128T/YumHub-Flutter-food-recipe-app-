import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:food_recipe_app/screens/random_recipe/widgets/equipment.dart';
import 'package:food_recipe_app/screens/random_recipe/widgets/nutrients.dart';
import '../../../animation/animation.dart';
import 'package:food_recipe_app/models/user_ingredient_list.dart';
import 'package:provider/provider.dart';
import '../../../models/equipment.dart';
import '../../../models/nutrients.dart';
import '../../../models/similar_list.dart';
import 'ingredients.dart';
import 'similar_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'appbar.dart';

class AddAllIngredientsButton extends StatefulWidget {
  final List<ExtendedIngredient>? ingredients;
  final String recipeId;
  final String recipeTitle;
  final String? recipeImage;

  const AddAllIngredientsButton({
    Key? key,
    required this.ingredients,
    required this.recipeId,
    required this.recipeTitle,
    this.recipeImage,
  }) : super(key: key);

  @override
  _AddAllIngredientsButtonState createState() =>
      _AddAllIngredientsButtonState();
}

class _AddAllIngredientsButtonState extends State<AddAllIngredientsButton>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _sizeAnimation =
        Tween<double>(begin: 78.0, end: 250.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void handleTapOutside() {
    if (_isExpanded) {
      _toggleExpanded();
    }
  }

  void _addAllIngredients(BuildContext context) {
    final userIngredientList =
        Provider.of<UserIngredientList>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final recipe = Recipe(
        id: int.tryParse(widget.recipeId),
        title: widget.recipeTitle,
        image: widget.recipeImage,
        extendedIngredients: widget.ingredients,
      );
      userIngredientList.addRecipe(recipe, user.uid);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All ingredients added to the ingredient manager.'),
        duration: Duration(seconds: 2),
      ),
    );
    _toggleExpanded();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizedBox(
          width: _sizeAnimation.value,
          height: 65.0,
          child: ElevatedButton.icon(
            onPressed: _isExpanded
                ? () => _addAllIngredients(context)
                : _toggleExpanded,
            icon: Icon(_isExpanded ? Icons.close : Icons.add),
            label: _isExpanded
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Add All Ingredients'),
                  )
                : const SizedBox.shrink(),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.center,
            ),
          ),
        );
      },
    );
  }
}

class RacipeInfoWidget extends StatefulWidget {
  final Recipe info;
  final List<Similar> similarlist;
  final List<Equipment> equipment;
  final Nutrient nutrient;
  final String recipeId;

  const RacipeInfoWidget({
    Key? key,
    required this.info,
    required this.similarlist,
    required this.equipment,
    required this.nutrient,
    required this.recipeId,
  }) : super(key: key);

  @override
  State<RacipeInfoWidget> createState() => _RacipeInfoWidgetState();
}

class _RacipeInfoWidgetState extends State<RacipeInfoWidget> {
  final GlobalKey<_AddAllIngredientsButtonState> _addIngredientsButtonKey =
      GlobalKey<_AddAllIngredientsButtonState>();

  void _handleTapOutside() {
    _addIngredientsButtonKey.currentState?.handleTapOutside();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _handleTapOutside,
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate:
                      MySliverAppBar(expandedHeight: 300, info: widget.info),
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
                      if (widget.info.analyzedInstructions != null &&
                          widget.info.analyzedInstructions!.isNotEmpty)
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
                              ...widget.info.analyzedInstructions!
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final instructionIndex = entry.key;
                                final instruction = entry.value;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (instruction.name != null &&
                                        instruction.name!.isNotEmpty)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        color: Colors.grey[200],
                                        child: Text(
                                          instruction.name!,
                                          style: GoogleFonts.chivo(
                                            textStyle: const TextStyle(
                                              fontSize: 17.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ...instruction.steps!
                                        .asMap()
                                        .entries
                                        .map((stepEntry) {
                                      final stepIndex = stepEntry.key;
                                      final step = stepEntry.value;
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.orange,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    (stepIndex + 1).toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: RichText(
                                                    textAlign:
                                                        TextAlign.justify,
                                                    text: TextSpan(
                                                      text: step.step,
                                                      style: GoogleFonts.chivo(
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 14.0,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (step.ingredients != null &&
                                                step.ingredients!.isNotEmpty)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    "🥕 Ingredients:",
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  ...step.ingredients!
                                                      .map((ingredient) {
                                                    return Text(
                                                      "- ${ingredient.name}",
                                                      style: const TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  }).toList(),
                                                ],
                                              ),
                                            if (step.equipment != null &&
                                                step.equipment!.isNotEmpty)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    "🍳 Utensils:",
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  ...step.equipment!
                                                      .map((equipment) {
                                                    return Text(
                                                      "- ${equipment.name}",
                                                      style: const TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  }).toList(),
                                                ],
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      if (widget.equipment.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(26.0),
                          child: Text(
                            "Utensils",
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
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 25,
            right: 35,
            child: AddAllIngredientsButton(
              key: _addIngredientsButtonKey,
              ingredients: widget.info.extendedIngredients,
              recipeId: widget.recipeId,
              recipeTitle: widget.info.title ?? 'Unknown Recipe',
              recipeImage: widget.info.image,
            ),
          ),
        ],
      ),
    );
  }
}
