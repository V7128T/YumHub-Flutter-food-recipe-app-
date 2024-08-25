import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../custom_colors/app_colors.dart';

String capitalize(String s) =>
    s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final Recipe info;
  MySliverAppBar({
    required this.expandedHeight,
    required this.info,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: maxExtent),
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Positioned(
            child: Container(
              color: Colors.black,
              child: Opacity(
                opacity: (1 - shrinkOffset / expandedHeight),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: info.image!,
                      height: expandedHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    Container(
                      height: expandedHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppBarWidget(
            expandedHeight: expandedHeight,
            shrinkOffset: shrinkOffset,
            recipe: info,
          ),
          Positioned(
            bottom: -60,
            left: 20,
            right: 20,
            child: Opacity(
              opacity: (1 - shrinkOffset / expandedHeight),
              child: _buildOverlappingInfoBox(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlappingInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  capitalize(info.title!),
                  style: GoogleFonts.playfairDisplay(
                    textStyle: TextStyle(
                      fontSize: 24.0,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildRating(),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoItem("${info.readyInMinutes} Min", "Prep. time"),
              _buildInfoDivider(),
              _buildInfoItem(info.servings.toString(), "Servings"),
              _buildInfoDivider(),
              _buildInfoItem('\$${info.pricePerServing}', "Price/Serving"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                fontSize: 18.0,
                color: Colors.orange[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.montserratAlternates(
              textStyle: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.orange[200],
    );
  }

  Widget _buildRating() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            info.spoonacularScore?.toStringAsFixed(1) ?? 'N/A',
            style: GoogleFonts.chivo(
              textStyle: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration(
        stretchTriggerOffset: maxExtent,
      );
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

class AppBarWidget extends StatefulWidget {
  const AppBarWidget({
    super.key,
    required this.expandedHeight,
    required this.shrinkOffset,
    required this.recipe,
  });

  final double expandedHeight;
  final double shrinkOffset;
  final Recipe recipe;

  @override
  _AppBarWidgetState createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  void _shareRecipe(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Share Recipe',
              style: GoogleFonts.chivo(fontWeight: FontWeight.bold)),
          content: Text(
              'Do you want to share the Spoonacular website URL for this recipe?',
              style: GoogleFonts.chivo()),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.chivo()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Share',
                  style: GoogleFonts.chivo(color: Colors.orange[800])),
              onPressed: () {
                Navigator.of(context).pop();
                Share.share(
                    widget.recipe.spoonacularSourceUrl ??
                        'https://spoonacular.com',
                    subject: 'Check out this recipe: ${widget.recipe.title}');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: true,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.7),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 10.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.7),
            ),
            child: IconButton(
              onPressed: () => _shareRecipe(context),
              iconSize: 25.0,
              visualDensity: VisualDensity.standard,
              icon: const Icon(CupertinoIcons.share, color: Colors.black),
            ),
          ),
        )
      ],
      title: Opacity(
        opacity: (0 + widget.shrinkOffset / widget.expandedHeight),
        child: Text(
          "YumHub",
          style: GoogleFonts.playfairDisplay(
            textStyle: const TextStyle(
              fontSize: 25.0,
              color: AppColors.secFont,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
