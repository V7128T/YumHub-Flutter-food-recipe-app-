import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_recipe_app/models/user_ingredient_list.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DeleteHistorySheet extends StatefulWidget {
  const DeleteHistorySheet({super.key});

  @override
  _DeleteHistorySheetState createState() => _DeleteHistorySheetState();
}

class _DeleteHistorySheetState extends State<DeleteHistorySheet> {
  @override
  Widget build(BuildContext context) {
    final userIngredientList = Provider.of<UserIngredientList>(context);
    final recentlyDeletedRecipes =
        userIngredientList.getRecentlyDeletedRecipes();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recently Deleted Recipes',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _clearAllRecipes(context),
                              icon: const Icon(Icons.delete_sweep),
                              label: const Text('Clear All'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: recentlyDeletedRecipes.isEmpty
                    ? Center(
                        child: Text(
                          'No deleted recipes',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        itemCount: recentlyDeletedRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recentlyDeletedRecipes[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) => _permanentlyRemoveRecipe(
                                        context, recipe),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete_forever,
                                    label: 'Delete',
                                  ),
                                  SlidableAction(
                                    onPressed: (_) =>
                                        _restoreRecipe(context, recipe),
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    icon: Icons.restore,
                                    label: 'Restore',
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  title: Text(
                                    recipe.title ?? 'Unknown Recipe',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Removed on ${_formatDate(recipe.dateRemoved)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.orange[100],
                                    child: Text(
                                      recipe.title?[0] ?? '?',
                                      style: GoogleFonts.poppins(
                                        color: Colors.orange[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    return date != null
        ? '${date.day}/${date.month}/${date.year}'
        : 'Unknown date';
  }

  void _permanentlyRemoveRecipe(BuildContext context, Recipe recipe) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Provider.of<UserIngredientList>(context, listen: false)
          .permanentlyRemoveRecipe(user.uid, recipe.id.toString());
    }
  }

  void _restoreRecipe(BuildContext context, Recipe recipe) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Provider.of<UserIngredientList>(context, listen: false)
          .restoreRecipe(user.uid, recipe);
      // Refresh the list
      setState(() {});
    }
  }

  void _clearAllRecipes(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear All Recipes',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text(
              'Are you sure you want to permanently delete all recipes in the history?',
              style: GoogleFonts.poppins()),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.poppins()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  Text('Clear', style: GoogleFonts.poppins(color: Colors.red)),
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  Provider.of<UserIngredientList>(context, listen: false)
                      .clearAllDeletedRecipes(user.uid);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
