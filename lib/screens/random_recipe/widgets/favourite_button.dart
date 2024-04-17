import 'package:flutter/material.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:hive/hive.dart';


///Heart Button : Adding Items in favourite list
class FavoriteButton extends StatelessWidget {
  final Recipe info;
  const FavoriteButton({Key? key, required this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () {
        ///Deleting info
        final box = Hive.box("Favorite");
        box.delete(info.id);
      },
      child: const Icon(
        Icons.favorite,
      ),
    );
  }
}
