import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_recipe_app/models/user_ingredient_list.dart';

class IngredientManagerPage extends StatefulWidget {
  const IngredientManagerPage({super.key});

  @override
  _IngredientManagerPageState createState() => _IngredientManagerPageState();
}

class _IngredientManagerPageState extends State<IngredientManagerPage> {
  @override
  Widget build(BuildContext context) {
    final userIngredientList = Provider.of<UserIngredientList>(context);
    final recipeIngredients = userIngredientList.ingredients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Manager'),
      ),
      body: recipeIngredients.isEmpty
          ? Center(
              child: Text(
                'No ingredients added yet.',
                style: Theme.of(context).textTheme.headline6,
              ),
            )
          : ListView.builder(
              itemCount: recipeIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = recipeIngredients[index];
                return Dismissible(
                  key: ObjectKey(ingredient),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    userIngredientList.removeIngredient(ingredient);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: ListTile(
                    title: Text(ingredient.name ?? ''),
                    subtitle: Text(
                        'Quantity: ${ingredient.amount ?? ''} ${ingredient.unit ?? ''}'),
                    onTap: () {
                      // Handle editing the ingredient
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle adding a new ingredient
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
