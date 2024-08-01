import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_app/models/categorized_ingredients.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';
import 'package:food_recipe_app/models/user_ingredient_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_recipe_app/models/recipe.dart';

class IngredientManagerPage extends StatefulWidget {
  const IngredientManagerPage({super.key});

  @override
  _IngredientManagerPageState createState() => _IngredientManagerPageState();
}

class _IngredientManagerPageState extends State<IngredientManagerPage> {
  bool _showCombinedView = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserIngredients();
  }

  Future<void> _loadUserIngredients() async {
    try {
      setState(() => _isLoading = true);
      final userIngredientList =
          Provider.of<UserIngredientList>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await userIngredientList.loadUserIngredients(user.uid);
      }
    } catch (e) {
      _showErrorDialog('Failed to load ingredients: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An error occurred'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  void _toggleViewMode() =>
      setState(() => _showCombinedView = !_showCombinedView);

  @override
  Widget build(BuildContext context) {
    final userIngredientList = Provider.of<UserIngredientList>(context);
    final userRecipes = userIngredientList.userRecipes;
    final categorizedIngredients =
        userIngredientList.getCategorizedIngredients();

    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery List',
            style: GoogleFonts.chivo(
              textStyle: const TextStyle(
                  fontSize: 25.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            )),
        actions: [
          IconButton(
            icon: Icon(_showCombinedView ? Icons.list : Icons.grid_view),
            onPressed: _toggleViewMode,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : userRecipes.isEmpty
              ? _buildEmptyState()
              : _showCombinedView
                  ? _buildCategorizedView(categorizedIngredients)
                  : _buildRecipeView(userIngredientList),
      floatingActionButton: userIngredientList.canUndo
          ? FloatingActionButton(
              onPressed: () => _undoDeleteRecipe(context),
              child: const Icon(Icons.undo),
            )
          : null,
    );
  }

  Future<void> _undoDeleteRecipe(BuildContext context) async {
    final userIngredientList =
        Provider.of<UserIngredientList>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await userIngredientList.undoDeleteRecipe(user.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe restored successfully')),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 64.0, color: Colors.grey),
          const SizedBox(height: 16.0),
          Text('No ingredients added yet.',
              style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildCategorizedView(
      List<CategorizedIngredients> categorizedIngredients) {
    return ListView.builder(
      itemCount: categorizedIngredients.length,
      itemBuilder: (context, index) {
        final category = categorizedIngredients[index];
        return ExpansionTile(
          title: Text(category.category),
          children: category.ingredients
              .map((ingredient) => _buildIngredientTile(ingredient, null))
              .toList(),
        );
      },
    );
  }

  Widget _buildRecipeView(UserIngredientList userIngredientList) {
    return ListView.builder(
      itemCount: userIngredientList.userRecipes.length,
      itemBuilder: (context, index) {
        final recipeId = userIngredientList.userRecipes.keys.elementAt(index);
        final recipe = userIngredientList.userRecipes[recipeId];
        if (recipe == null) return const SizedBox.shrink();

        final uniqueKey = ValueKey('recipe-$recipeId');

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Dismissible(
            key: uniqueKey,
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _removeRecipe(recipe),
            background: Container(
              decoration: BoxDecoration(
                color: Colors.red.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ExpansionTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: recipe.image ?? '',
                      width: 60,
                      height: 60,
                      memCacheWidth: 157,
                      memCacheHeight: 147,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(
                    recipe.title ?? 'Unknown Recipe',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Ready in ${recipe.readyInMinutes ?? 'N/A'} Min',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 14,
                    ),
                  ),
                  children: recipe.extendedIngredients?.isEmpty ?? true
                      ? [
                          const ListTile(
                            title: Text('No ingredients for this recipe'),
                            textColor: Colors.grey,
                          )
                        ]
                      : recipe.extendedIngredients!
                          .map((ingredient) =>
                              _buildIngredientTile(ingredient, recipe))
                          .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientTile(ExtendedIngredient ingredient, Recipe? recipe) {
    final uniqueKey = ValueKey(
        '${recipe?.id ?? 'combined'}-${ingredient.uniqueId}-${DateTime.now().microsecondsSinceEpoch}');

    return Dismissible(
      key: uniqueKey,
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeIngredient(ingredient, recipe),
      background: Container(
        color: Colors.red.shade100,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.red.shade700),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          ingredient.name ?? '',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${ingredient.amount?.toStringAsFixed(2) ?? ''} ${ingredient.unit ?? ''}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _editIngredient(ingredient, recipe),
        ),
      ),
    );
  }

  Future<void> _removeRecipe(Recipe recipe) async {
    try {
      final userIngredientList =
          Provider.of<UserIngredientList>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && recipe.id != null) {
        userIngredientList.clearRecipe(user.uid, recipe.id.toString());
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe removed successfully')));
      }
    } catch (e) {
      _showErrorDialog('Failed to remove recipe: $e');
    }
  }

  Future<void> _removeIngredient(
      ExtendedIngredient ingredient, Recipe? recipe) async {
    try {
      final userIngredientList =
          Provider.of<UserIngredientList>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && recipe != null && recipe.id != null) {
        userIngredientList.removeIngredient(user.uid, recipe.id.toString(),
            ingredient, recipe.title ?? 'Unknown Recipe');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingredient removed successfully')));
      }
    } catch (e) {
      _showErrorDialog('Failed to remove ingredient: $e');
    }
  }

  void _editIngredient(ExtendedIngredient ingredient, Recipe? recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? name = ingredient.name;
        double? amount = ingredient.amount;
        String? unit = ingredient.unit;

        return AlertDialog(
          title: const Text('Edit Ingredient'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  controller: TextEditingController(text: name),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  controller: TextEditingController(text: amount?.toString()),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => amount = double.tryParse(value),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Unit'),
                  controller: TextEditingController(text: unit),
                  onChanged: (value) => unit = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                Navigator.of(context).pop();
                if (recipe != null) {
                  await _updateIngredient(
                      ingredient, recipe, name, amount, unit);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateIngredient(ExtendedIngredient ingredient, Recipe recipe,
      String? name, double? amount, String? unit) async {
    try {
      final userIngredientList =
          Provider.of<UserIngredientList>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        ExtendedIngredient updatedIngredient = ingredient.copyWith(
          name: name,
          amount: amount,
          unit: unit,
        );

        await userIngredientList.updateIngredient(
            user.uid,
            recipe.id.toString(),
            updatedIngredient,
            recipe.title ?? 'Unknown Recipe');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingredient updated successfully')));
      }
    } catch (e) {
      _showErrorDialog('Failed to update ingredient: $e');
    }
  }
}
