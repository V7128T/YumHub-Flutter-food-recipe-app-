import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/models/categorized_ingredients.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:food_recipe_app/models/shopping_list_item.dart';
import 'package:food_recipe_app/screens/profile_screen/bloc/profile_event.dart';
import 'package:food_recipe_app/screens/recipe_info/bloc/recipe_info_bloc.dart';
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
import 'package:food_recipe_app/screens/utils.dart';
import '../../custom_colors/app_colors.dart';
import '../profile_screen/bloc/profile_bloc.dart';

class IngredientManagerPage extends StatefulWidget {
  const IngredientManagerPage({super.key});

  @override
  State<IngredientManagerPage> createState() => _IngredientManagerPageState();
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
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isAnonymous = user?.isAnonymous ?? true;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Grocery List',
          style: GoogleFonts.playfairDisplay(
            textStyle: const TextStyle(
              fontSize: 25.0,
              color: AppColors.secFont,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: isAnonymous
            ? []
            : [
                IconButton(
                  icon: Icon(_showCombinedView ? Icons.list : Icons.grid_view,
                      color: AppColors.primFont),
                  onPressed: _toggleViewMode,
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart,
                      color: AppColors.primFont),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[50]!, Colors.orange[100]!],
          ),
        ),
        child: SafeArea(
          child:
              isAnonymous ? _buildGuestOverlay() : _buildAuthenticatedContent(),
        ),
      ),
      floatingActionButton: isAnonymous ? null : _buildFloatingActionButton(),
      floatingActionButtonLocation: const CustomFabLocation(offsetY: 80),
    );
  }

  Widget _buildGuestOverlay() {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'You are logged in as a guest.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => showGuestOverlay(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Create an Account'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticatedContent() {
    final userIngredientList = Provider.of<UserIngredientList>(context);
    final userRecipes = userIngredientList.userRecipes;
    final categorizedIngredients =
        userIngredientList.getCategorizedIngredients();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (userRecipes.isEmpty) {
      return _buildEmptyState();
    } else {
      return _showCombinedView
          ? _buildCategorizedView(categorizedIngredients)
          : _buildRecipeView(userIngredientList);
    }
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.orange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: FloatingActionButton(
        onPressed: () => _showDeleteHistory(context),
        backgroundColor: AppColors.primFont,
        elevation: 0,
        child: const Icon(
          Icons.history,
          color: AppColors.defaultWhite,
          size: 27,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu,
              size: 64.0, color: AppColors.primFont),
          const SizedBox(height: 16.0),
          Text(
            'No ingredients added yet.',
            style: GoogleFonts.robotoSerif(
              textStyle: TextStyle(
                fontSize: 18.0,
                color: Colors.orange[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorizedView(
      List<CategorizedIngredients> categorizedIngredients) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(bottom: 70, top: 10),
              itemCount: categorizedIngredients.length,
              itemBuilder: (context, index) {
                final category = categorizedIngredients[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      category.category,
                      style: GoogleFonts.chivo(
                        textStyle: TextStyle(
                          fontSize: 18.0,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    children: category.ingredients.map((ingredient) {
                      // Find the recipe that contains this ingredient
                      Recipe? containingRecipe =
                          _findRecipeForIngredient(ingredient);
                      return _buildIngredientTile(
                        ingredient,
                        containingRecipe,
                      );
                    }).toList(),
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
                    backgroundColor: Colors.orange[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Add to Shopping List",
                    style: GoogleFonts.chivo(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Recipe? _findRecipeForIngredient(ExtendedIngredient ingredient) {
    final userIngredientList =
        Provider.of<UserIngredientList>(context, listen: false);
    for (var recipe in userIngredientList.userRecipes.values) {
      if (recipe.extendedIngredients
              ?.any((i) => i.uniqueId == ingredient.uniqueId) ??
          false) {
        return recipe;
      }
    }
    return null;
  }

  Widget _buildRecipeView(UserIngredientList userIngredientList) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 70, top: 10),
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
                  confirmDismiss: (DismissDirection direction) async {
                    return await showRecipeDeleteConfirmationDialog(context);
                  },
                  background: Container(
                    color: Colors.red.shade100,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.red.shade700),
                  ),
                  onDismissed: (_) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      userIngredientList.clearRecipe(
                          user.uid, recipe.id.toString());
                      final newCount = userIngredientList.userRecipes.length;
                      context
                          .read<ProfileBloc>()
                          .add(UpdateRecipesCount(newCount));
                    }
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                        style: GoogleFonts.playfairDisplay(
                          textStyle: const TextStyle(
                            fontSize: 16.0,
                            color: AppColors.secFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      subtitle: Text(
                        'Added on ${_formatDate(recipe.dateAdded)}',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
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
                backgroundColor: Colors.orange[800],
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

  Widget _buildIngredientTile(ExtendedIngredient ingredient, Recipe? recipe) {
    final uniqueKey = ValueKey(
        '${recipe?.id ?? 'combined'}-${ingredient.uniqueId}-${DateTime.now().microsecondsSinceEpoch}');

    return Dismissible(
      key: uniqueKey,
      direction: DismissDirection.endToStart,
      confirmDismiss: (DismissDirection direction) async {
        return await showIngredientDeleteConfirmationDialog(context);
      },
      onDismissed: (_) => _removeIngredient(ingredient, recipe),
      background: Container(
        color: Colors.red.shade100,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.red.shade700),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.orange[100]!, width: 1),
          ),
        ),
        child: ListTile(
          title: Text(
            ingredient.name ?? '',
            style: GoogleFonts.montserratAlternates(
              textStyle: const TextStyle(
                fontSize: 14.0,
                color: AppColors.secFont,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          subtitle: Text(
            '${ingredient.amount} ${ingredient.unit} (${ingredient.convertedAmount?.toStringAsFixed(2) ?? ingredient.amount?.toStringAsFixed(2) ?? ''} ${ingredient.convertedUnit ?? ingredient.unit ?? ''})',
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.orange[600]),
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
                activeColor: Colors.orange[800],
              ),
            ],
          ),
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

  Future<bool?> showIngredientDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Confirm Delete',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: Colors.orange[800])),
          content: Text(
              'Are you sure you want to remove this ingredient from this recipe?',
              style: GoogleFonts.poppins()),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey[600])),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Delete',
                  style: GoogleFonts.poppins(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> showRecipeDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Confirm Delete',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: Colors.orange[800])),
          content: Text(
              'Are you sure you want to remove this recipe from the list?',
              style: GoogleFonts.poppins()),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey[600])),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Delete',
                  style: GoogleFonts.poppins(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }
}
