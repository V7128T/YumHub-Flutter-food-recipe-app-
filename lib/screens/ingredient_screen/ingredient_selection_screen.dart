import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';
import 'package:food_recipe_app/models/user_ingredient_list.dart';
import 'package:food_recipe_app/repo/get_recipe_info.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:food_recipe_app/services/conversion_service.dart';

import '../profile_screen/bloc/profile_bloc.dart';
import '../profile_screen/bloc/profile_event.dart';

class IngredientSelectionScreen extends StatefulWidget {
  final List<ExtendedIngredient> recipeIngredients;
  final String recipeId;
  final String recipeTitle;

  const IngredientSelectionScreen({
    super.key,
    required this.recipeIngredients,
    required this.recipeId,
    required this.recipeTitle,
  });

  @override
  _IngredientSelectionScreenState createState() =>
      _IngredientSelectionScreenState();
}

class _IngredientSelectionScreenState extends State<IngredientSelectionScreen> {
  List<ExtendedIngredient> _recipeIngredients = [];
  final Set<ExtendedIngredient> _selectedIngredients = {};
  bool _isLoading = false;
  final ConversionService _conversionService = ConversionService();

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

  Future<void> _convertIngredient(ExtendedIngredient ingredient) async {
    print("Attempting to convert: ${ingredient.name}");

    if (ingredient.amount != null && ingredient.unit != null) {
      try {
        final result = await _conversionService.convertAmount(
          ingredientName: ingredient.name ?? '',
          sourceAmount: ingredient.amount!,
          sourceUnit: ingredient.unit!,
          targetUnit: 'grams',
        );

        print("Conversion API response: $result");

        if (result.containsKey('targetAmount') &&
            result.containsKey('targetUnit')) {
          ingredient.convertedAmount = result['targetAmount'];
          ingredient.convertedUnit = result['targetUnit'];
          print(
              "Conversion successful: ${ingredient.convertedAmount} ${ingredient.convertedUnit}");
        } else {
          print("Conversion API did not return expected data");
        }
      } catch (e) {
        print('Error converting ingredient ${ingredient.name}: $e');
      }
    } else {
      print("Skipping conversion due to null amount or unit");
    }

    print(
        "Final converted values: ${ingredient.convertedAmount} ${ingredient.convertedUnit}");
  }

  Future<void> _addSelectedIngredients() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        print("Starting ingredient conversion");
        for (var ingredient in _selectedIngredients) {
          print("Converting ingredient: ${ingredient.name}");
          await _convertIngredient(ingredient);
          print(
              "After conversion: ${ingredient.name} - Converted: ${ingredient.convertedAmount} ${ingredient.convertedUnit}");
        }
        print("Conversion complete");

        final recipe = Recipe(
          id: int.tryParse(widget.recipeId),
          title: widget.recipeTitle,
          extendedIngredients: _selectedIngredients.toList(),
        );

        print(
            "Recipe before adding: ${recipe.extendedIngredients?.map((e) => '${e.name}: ${e.convertedAmount} ${e.convertedUnit}').join(', ')}");

        await Provider.of<UserIngredientList>(context, listen: false)
            .addRecipe(recipe, user.uid);
        final newCount = Provider.of<UserIngredientList>(context, listen: false)
            .userRecipes
            .length;
        context.read<ProfileBloc>().add(UpdateRecipesCount(newCount));
        Navigator.pop(context);
      } catch (e) {
        print("Error in _addSelectedIngredients: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add ingredients: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Ingredients'),
      ),
      body: Stack(
        children: [
          ListView.builder(
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _addSelectedIngredients,
        child: const Icon(Icons.add),
      ),
    );
  }
}
