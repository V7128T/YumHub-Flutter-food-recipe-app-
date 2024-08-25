import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/models/food_type.dart';
import 'package:food_recipe_app/screens/recipe_info/bloc/recipe_info_bloc.dart';
import 'package:food_recipe_app/screens/recipe_info/recipe_info_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../custom_colors/app_colors.dart';

String capitalize(String s) =>
    s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

class FoodTypeWidget extends StatelessWidget {
  final List<FoodType> items;

  const FoodTypeWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      // Wrap with Column
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            // store this controller in a State to save the carousel scroll position
            children: [
              const SizedBox(width: 20),
              ...items.map((item) {
                return RecipeCardType(items: item);
              }).toList()
            ],
          ),
        ),
      ],
    );
  }
}

class RecipeCardType extends StatefulWidget {
  const RecipeCardType({
    super.key,
    required this.items,
  });

  final FoodType items;

  @override
  _RecipeCardTypeState createState() => _RecipeCardTypeState();
}

class _RecipeCardTypeState extends State<RecipeCardType> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => RecipeInfoBloc(),
                  child: RecipeInfo(
                    id: widget.items.id,
                  ),
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: CachedNetworkImage(
                  imageUrl: widget.items.image,
                  fit: BoxFit.cover,
                  height: 150,
                  width: double.infinity,
                  memCacheHeight: 150,
                  memCacheWidth: 200,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capitalize(widget.items.name),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        textStyle: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: AppColors.primFont),
                        const SizedBox(width: 4),
                        Text(
                          "Ready in ${widget.items.readyInMinutes} Min",
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              fontSize: 13.0,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
