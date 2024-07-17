import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';
import 'package:food_recipe_app/models/user_ingredient_list.dart';
import 'package:food_recipe_app/repo/get_recipe_info.dart';

class IngredientSelectionScreen extends StatefulWidget {
  final List<ExtendedIngredient> recipeIngredients;
  final String recipeId;

  const IngredientSelectionScreen({
    super.key,
    required this.recipeIngredients,
    required this.recipeId,
  });

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
      // Handle any errors that occur during the API call
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
    Provider.of<UserIngredientList>(context, listen: false)
        .addIngredients(_selectedIngredients, widget.recipeId);
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
