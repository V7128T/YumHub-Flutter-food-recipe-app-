import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';
import 'package:food_recipe_app/models/user_ingredient_list.dart';
import 'package:food_recipe_app/repo/get_recipe_info.dart';
import 'package:food_recipe_app/models/recipe.dart';

class IngredientSelectionScreen extends StatefulWidget {
  final List<ExtendedIngredient> recipeIngredients;
  final String recipeId;
  final String recipeTitle;

  const IngredientSelectionScreen({
    Key? key,
    required this.recipeIngredients,
    required this.recipeId,
    required this.recipeTitle,
  }) : super(key: key);

  @override
  _IngredientSelectionScreenState createState() =>
      _IngredientSelectionScreenState();
}

class _IngredientSelectionScreenState extends State<IngredientSelectionScreen> {
  List<ExtendedIngredient> _recipeIngredients = [];
  final Set<ExtendedIngredient> _selectedIngredients = {};

  @override
  void initState() {
    super.initState();
    _fetchRecipeIngredients();
  }

  Future<void> _fetchRecipeIngredients() async {
    final recipeId = widget.recipeId;
    final ingredients = await fetchRecipeIngredients(recipeId);
    setState(() {
      _recipeIngredients = ingredients;
    });
  }

  Future<List<ExtendedIngredient>> fetchRecipeIngredients(
      String recipeId) async {
    try {
      final getRecipeInfo = GetRecipeInfo();
      final recipeData = await getRecipeInfo.getRecipeInfo(recipeId);
      return recipeData[0].extendedIngredients ?? [];
    } catch (e) {
      print('Error fetching recipe ingredients: $e');
      return [];
    }
  }

  void _toggleIngredient(ExtendedIngredient ingredient) {
    setState(() {
      if (_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.remove(ingredient);
      } else {
        _selectedIngredients.add(ingredient);
      }
    });
  }

  void _addSelectedIngredients() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final recipe = Recipe(
        id: int.tryParse(widget.recipeId),
        title: widget.recipeTitle,
        extendedIngredients: _selectedIngredients.toList(),
      );
      Provider.of<UserIngredientList>(context, listen: false)
          .addRecipe(recipe, user.uid);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Ingredients'),
      ),
      body: ListView.builder(
        itemCount: _recipeIngredients.length,
        itemBuilder: (context, index) {
          final ingredient = _recipeIngredients[index];
          return CheckboxListTile(
            title: Text(ingredient.name ?? ''),
            subtitle:
                Text('${ingredient.amount ?? ''} ${ingredient.unit ?? ''}'),
            value: _selectedIngredients.contains(ingredient),
            onChanged: (_) => _toggleIngredient(ingredient),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSelectedIngredients,
        child: const Icon(Icons.add),
      ),
    );
  }
}
