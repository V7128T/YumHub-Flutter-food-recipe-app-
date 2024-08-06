import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/models/categorized_ingredients.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:food_recipe_app/models/shopping_list_item.dart';
import 'package:food_recipe_app/screens/recipe_info/bloc/recipe_info_bloc.dart';
import 'package:food_recipe_app/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:food_recipe_app/models/extended_ingredient.dart';
import 'package:food_recipe_app/models/user_ingredient_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_recipe_app/screens/recipe_info/recipe_info_screen.dart'
    as RecipeInfoPage;
import 'package:food_recipe_app/screens/ingredient_screen/delete_history.dart';
import 'package:food_recipe_app/custom_dialogs/custom_fab_location.dart';
import 'package:food_recipe_app/screens/shopping_list/shopping_list_manager.dart';
import 'package:food_recipe_app/screens/shopping_list/shopping_list_screen.dart';
import 'package:uuid/uuid.dart';

class IngredientManagerPage extends StatefulWidget {
  const IngredientManagerPage({super.key});

  @override
  _IngredientManagerPageState createState() => _IngredientManagerPageState();
}

class _IngredientManagerPageState extends State<IngredientManagerPage> {
  bool _showCombinedView = false;
  bool _isLoading = true;
  final Set<String> _selectedIngredients = {};
  final ShoppingListManager _shoppingListManager = ShoppingListManager();

  @override
  void initState() {
    super.initState();
    _loadUserIngredients();
    _loadDeleteHistory();
  }

  Future<void> _loadUserIngredients() async {
    try {
      setState(() => _isLoading = true);
      final userIngredientList =
          Provider.of<UserIngredientList>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await userIngredientList.loadUserIngredients(user.uid);
        setState(() {});
      }
    } catch (e) {
      _showErrorDialog('Failed to load ingredients: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDeleteHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await Provider.of<UserIngredientList>(context, listen: false)
          .loadDeleteHistory(user.uid);
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
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ShoppingListScreen(),
                ),
              );
            },
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
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          width: 56.0,
          height: 56.0,
          decoration: BoxDecoration(
            color: Colors.orangeAccent,
            border: Border.all(color: Colors.orangeAccent, width: 2.0),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              onTap: () => _showDeleteHistory(context),
              child: const Center(
                child: Icon(
                  Icons.history,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: const CustomFabLocation(offsetY: 80),
    );
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
    return Stack(
      children: [
        ListView.builder(
          padding:
              const EdgeInsets.only(bottom: 70), // Add padding for the button
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
        ),
        if (_hasSelectedIngredients)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _addToShoppingList,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                "Add to Shopping List",
                style: GoogleFonts.chivo(
                  textStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Widget _buildRecipeView(UserIngredientList userIngredientList) {
  //   return ListView.builder(
  //     itemCount: userIngredientList.userRecipes.length,
  //     itemBuilder: (context, index) {
  //       final recipeId = userIngredientList.userRecipes.keys.elementAt(index);
  //       final recipe = userIngredientList.userRecipes[recipeId];
  //       if (recipe == null) return const SizedBox.shrink();

  //       final uniqueKey = ValueKey('recipe-$recipeId');

  //       return Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //         child: GestureDetector(
  //           onLongPress: () =>
  //               _navigateToRecipeInfo(context, recipe.id.toString()),
  //           child: Dismissible(
  //             key: uniqueKey,
  //             direction: DismissDirection.endToStart,
  //             onDismissed: (_) => _removeRecipe(recipe),
  //             background: Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.red.shade300,
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               alignment: Alignment.centerRight,
  //               padding: const EdgeInsets.only(right: 20),
  //               child: const Icon(Icons.delete, color: Colors.white),
  //             ),
  //             child: Card(
  //               elevation: 0,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //                 side: BorderSide(color: Colors.grey.shade200),
  //               ),
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(12),
  //                 child: ExpansionTile(
  //                   leading: ClipRRect(
  //                     borderRadius: BorderRadius.circular(8),
  //                     child: CachedNetworkImage(
  //                       imageUrl: recipe.image ?? '',
  //                       width: 60,
  //                       height: 60,
  //                       memCacheWidth: 157,
  //                       memCacheHeight: 147,
  //                       fit: BoxFit.cover,
  //                       placeholder: (context, url) => Container(
  //                         color: Colors.grey.shade200,
  //                         child:
  //                             const Center(child: CircularProgressIndicator()),
  //                       ),
  //                       errorWidget: (context, url, error) => Container(
  //                         color: Colors.grey.shade200,
  //                         child: const Icon(Icons.error, color: Colors.grey),
  //                       ),
  //                     ),
  //                   ),
  //                   title: Text(
  //                     recipe.title ?? 'Unknown Recipe',
  //                     style: const TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   subtitle: Text(
  //                     'Added on ${_formatDate(recipe.dateAdded)}',
  //                     style: TextStyle(
  //                       color: Colors.grey.shade600,
  //                       fontSize: 12,
  //                     ),
  //                   ),
  //                   children: recipe.extendedIngredients?.isEmpty ?? true
  //                       ? [
  //                           const ListTile(
  //                             title: Text('No ingredients for this recipe'),
  //                             textColor: Colors.grey,
  //                           )
  //                         ]
  //                       : recipe.extendedIngredients!
  //                           .map((ingredient) =>
  //                               _buildIngredientTile(ingredient, recipe))
  //                           .toList(),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildRecipeView(UserIngredientList userIngredientList) {
    return Stack(
      children: [
        ListView.builder(
          padding:
              const EdgeInsets.only(bottom: 70), // Add padding for the button
          itemCount: userIngredientList.userRecipes.length,
          itemBuilder: (context, index) {
            final recipeId =
                userIngredientList.userRecipes.keys.elementAt(index);
            final recipe = userIngredientList.userRecipes[recipeId];
            if (recipe == null) return const SizedBox.shrink();

            final uniqueKey = ValueKey('recipe-$recipeId');

            bool areAllIngredientsSelected = recipe.extendedIngredients?.every(
                  (ingredient) =>
                      _selectedIngredients.contains(ingredient.uniqueId),
                ) ??
                false;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onLongPress: () =>
                    _navigateToRecipeInfo(context, recipe.id.toString()),
                child: Dismissible(
                  key: uniqueKey,
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      userIngredientList.clearRecipe(
                          user.uid, recipe.id.toString());
                    }
                  },
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
                    child: ExpansionTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CachedNetworkImage(
                            imageUrl: recipe.image ?? '',
                            fit: BoxFit.cover,
                            memCacheWidth: 157,
                            memCacheHeight: 147,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child:
                                  const Icon(Icons.error, color: Colors.grey),
                            ),
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
                        'Added on ${_formatDate(recipe.dateAdded)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Checkbox(
                        value: areAllIngredientsSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedIngredients.addAll(
                                recipe.extendedIngredients
                                        ?.map((i) => i.uniqueId) ??
                                    [],
                              );
                            } else {
                              _selectedIngredients.removeAll(
                                recipe.extendedIngredients
                                        ?.map((i) => i.uniqueId) ??
                                    [],
                              );
                            }
                          });
                        },
                      ),
                      children: recipe.extendedIngredients?.isEmpty ?? true
                          ? [
                              const ListTile(
                                  title: Text('No ingredients for this recipe'))
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
        ),
        if (_hasSelectedIngredients)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _addToShoppingList,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                "Add to Shopping List",
                style: GoogleFonts.chivo(
                  textStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    return date != null
        ? '${date.day}/${date.month}/${date.year}'
        : 'Unknown date';
  }

  void _navigateToRecipeInfo(BuildContext context, String recipeId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => RecipeInfoBloc(),
          child: RecipeInfoPage.RecipeInfo(id: recipeId),
        ),
      ),
    );
  }

  void _showDeleteHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const DeleteHistorySheet(),
    );
  }

  // Widget _buildIngredientTile(ExtendedIngredient ingredient, Recipe? recipe) {
  //   final uniqueKey = ValueKey(
  //       '${recipe?.id ?? 'combined'}-${ingredient.uniqueId}-${DateTime.now().microsecondsSinceEpoch}');
  //   return Dismissible(
  //     key: uniqueKey,
  //     direction: DismissDirection.endToStart,
  //     onDismissed: (_) => _removeIngredient(ingredient, recipe),
  //     background: Container(
  //       color: Colors.red.shade100,
  //       alignment: Alignment.centerRight,
  //       padding: const EdgeInsets.only(right: 20),
  //       child: Icon(Icons.delete, color: Colors.red.shade700),
  //     ),
  //     child: ListTile(
  //       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  //       title: Text(
  //         ingredient.name ?? '',
  //         style: const TextStyle(fontWeight: FontWeight.w500),
  //       ),
  //       subtitle: Text(
  //         '${ingredient.convertedAmount?.toStringAsFixed(2) ?? ingredient.amount?.toStringAsFixed(2) ?? ''} ${ingredient.convertedUnit ?? ingredient.unit ?? ''}',
  //         style: TextStyle(color: Colors.grey.shade600),
  //       ),
  //       trailing: IconButton(
  //         icon: const Icon(Icons.edit, color: Colors.blue),
  //         onPressed: () => _editIngredient(ingredient, recipe),
  //       ),
  //     ),
  //   );
  // }

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${ingredient.convertedAmount?.toStringAsFixed(2) ?? ingredient.amount?.toStringAsFixed(2) ?? ''} ${ingredient.convertedUnit ?? ingredient.unit ?? ''}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editIngredient(ingredient, recipe),
            ),
            Checkbox(
              value: _selectedIngredients.contains(ingredient.uniqueId),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedIngredients.add(ingredient.uniqueId);
                  } else {
                    _selectedIngredients.remove(ingredient.uniqueId);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
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
                  final updatedIngredient = ingredient.copyWith(
                    name: name,
                    amount: amount,
                    unit: unit,
                  );
                  await _updateIngredient(updatedIngredient, recipe);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateIngredient(
      ExtendedIngredient updatedIngredient, Recipe recipe) async {
    final userIngredientList =
        Provider.of<UserIngredientList>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await userIngredientList.updateIngredient(
          user.uid,
          recipe.id.toString(),
          updatedIngredient,
          recipe.title ?? 'Unknown Recipe',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update ingredient: $e')),
        );
      }
    }
  }

  Future<void> _addToShoppingList() async {
    final userIngredientList =
        Provider.of<UserIngredientList>(context, listen: false);
    final apiService = ApiService();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      for (String ingredientId in _selectedIngredients) {
        final ingredient = userIngredientList.findIngredientById(ingredientId);
        if (ingredient != null) {
          final shoppingListItem = ShoppingListItem(
            id: const Uuid().v4(),
            name: ingredient.name ?? '',
            amount: ingredient.amount ?? 0,
            unit: ingredient.unit ?? '',
            recipeId: ingredient.recipeId,
            recipeName: ingredient.recipeName,
            added: DateTime.now(),
          );
          try {
            await _shoppingListManager.addToShoppingList(
                user.uid, shoppingListItem);
          } catch (e) {
            if (e.toString().contains('No similar products found')) {
              // Show dialog to user about missing product
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Product Not Found'),
                    content: Text(
                        '${ingredient.name} is not available in the store inventory.'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              // Handle other errors
              print('Error adding to shopping list: $e');
            }
          }
        }
      }
      setState(() {
        _selectedIngredients.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to shopping list')),
      );
    }
  }

  bool get _hasSelectedIngredients => _selectedIngredients.isNotEmpty;
}
