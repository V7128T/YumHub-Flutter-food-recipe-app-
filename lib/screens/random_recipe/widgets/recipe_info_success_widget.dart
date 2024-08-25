import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';
import 'package:food_recipe_app/models/ingredient.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:food_recipe_app/models/step.dart' as recipe_step;
import 'package:food_recipe_app/screens/random_recipe/widgets/equipment.dart';
import 'package:food_recipe_app/screens/random_recipe/widgets/nutrients.dart';
import 'package:food_recipe_app/screens/utils.dart';
import 'package:food_recipe_app/models/user_ingredient_list.dart';
import 'package:provider/provider.dart';
import '../../../custom_colors/app_colors.dart';
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
    super.key,
    required this.ingredients,
    required this.recipeId,
    required this.recipeTitle,
    this.recipeImage,
  });

  @override
  _AddAllIngredientsButtonState createState() =>
      _AddAllIngredientsButtonState();
}

class _AddAllIngredientsButtonState extends State<AddAllIngredientsButton>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void handleTapOutside() {
    if (_isExpanded) {
      _toggleExpanded();
    }
  }

  void _addAllIngredients() {
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
      SnackBar(
        content: const Text('All ingredients added to the ingredient manager.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    _toggleExpanded();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: _isExpanded ? 200 : 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange[800],
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _isExpanded
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _toggleExpanded,
                      ),
                      TextButton(
                        onPressed: _addAllIngredients,
                        child: Text(
                          'Add All',
                          style: GoogleFonts.chivo(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: _toggleExpanded,
                  ),
          ),
        );
      },
    );
  }
}

class RecipeInfoWidget extends StatefulWidget {
  final Recipe info;
  final List<Similar> similarlist;
  final List<Equipment> equipment;
  final Nutrient nutrient;
  final String recipeId;

  const RecipeInfoWidget({
    super.key,
    required this.info,
    required this.similarlist,
    required this.equipment,
    required this.nutrient,
    required this.recipeId,
  });

  @override
  State<RecipeInfoWidget> createState() => _RecipeInfoWidgetState();
}

final GlobalKey<_AddAllIngredientsButtonState> _addIngredientsButtonKey =
    GlobalKey<_AddAllIngredientsButtonState>();

void _handleTapOutside() {
  _addIngredientsButtonKey.currentState?.handleTapOutside();
}

class _RecipeInfoWidgetState extends State<RecipeInfoWidget> {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isAnonymous = user?.isAnonymous ?? true;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange[50]!, Colors.orange[200]!],
              ),
            ),
            child: GestureDetector(
              onTap: _handleTapOutside,
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    delegate:
                        MySliverAppBar(expandedHeight: 350, info: widget.info),
                    pinned: true,
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                            height: 70), // Add space for the overlapping box
                        _buildIngredients(),
                        _buildInstructions(),
                        _buildUtensils(),
                        _buildNutrients(),
                        _buildSimilarItems(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildAddIngredientsButton(isAnonymous),
        ],
      ),
    );
  }

  Widget _buildIngredients() {
    return _buildSection(
      "Ingredients",
      widget.info.extendedIngredients!.isNotEmpty
          ? IngredientsWidget(recipe: widget.info)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildInstructions() {
    if (widget.info.analyzedInstructions == null ||
        widget.info.analyzedInstructions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      "Instructions",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.info.analyzedInstructions!
            .expand((instruction) => [
                  if (instruction.name != null && instruction.name!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        instruction.name!,
                        style: GoogleFonts.chivo(
                          textStyle: TextStyle(
                            fontSize: 18.0,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ...instruction.steps!
                      .map((step) => _buildInstructionStep(step)),
                ])
            .toList(),
      ),
    );
  }

  Widget _buildInstructionStep(recipe_step.Step step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.orange[800],
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  (step.number ?? 0).toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.step ?? '',
                  style: GoogleFonts.robotoSerif(
                    textStyle: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (step.ingredients != null && step.ingredients!.isNotEmpty)
            _buildStepDetails(
                "🥕 Ingredients:", _extractIngredientNames(step.ingredients!)),
          if (step.equipment != null && step.equipment!.isNotEmpty)
            _buildStepDetails(
                "🍳 Utensils:", _extractEquipmentNames(step.equipment!)),
        ],
      ),
    );
  }

  List<String> _extractIngredientNames(List<Ingredient> ingredients) {
    return ingredients.map((ingredient) => ingredient.name ?? '').toList();
  }

  List<String> _extractEquipmentNames(List<Equipment> equipments) {
    return equipments.map((equipment) => equipment.name ?? '').toList();
  }

  Widget _buildStepDetails(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 14.0,
              color: Colors.orange[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items.map((item) => Text(
              "- $item",
              style: GoogleFonts.montserrat(
                textStyle: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal),
              ),
            )),
      ],
    );
  }

  Widget _buildUtensils() {
    return widget.equipment.isNotEmpty
        ? _buildSection(
            "Utensils",
            EquipmentsListView(equipments: widget.equipment),
          )
        : const SizedBox.shrink();
  }

  Widget _buildNutrients() {
    return _buildSection(
      "Nutrition Information",
      Column(
        children: [
          CompactNutritionWidget(nutrient: widget.nutrient),
        ],
      ),
    );
  }

  Widget _buildSimilarItems() {
    return widget.similarlist.isNotEmpty
        ? _buildSection(
            "Similar Recipes",
            SimilarListWidget(items: widget.similarlist),
          )
        : const SizedBox.shrink();
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              textStyle: const TextStyle(
                fontSize: 22.0,
                color: AppColors.secFont,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildAddIngredientsButton(bool isAnonymous) {
    return Positioned(
      bottom: 25,
      right: 25,
      child: isAnonymous
          ? ElevatedButton(
              onPressed: () => showGuestOverlay(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange[800],
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(Icons.add, size: 30),
            )
          : AddAllIngredientsButton(
              ingredients: widget.info.extendedIngredients,
              recipeId: widget.recipeId,
              recipeTitle: widget.info.title ?? 'Unknown Recipe',
              recipeImage: widget.info.image,
            ),
    );
  }
}
