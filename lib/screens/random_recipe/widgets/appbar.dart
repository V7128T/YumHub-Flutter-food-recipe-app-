import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:food_recipe_app/models/recipe.dart';
import 'package:food_recipe_app/screens/random_recipe/widgets/favourite_button.dart';
import 'package:google_fonts/google_fonts.dart';

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
        // overflow: Overflow.visible,
        children: [
          Positioned(
            child: Container(
              color: Colors.white,
              child: Opacity(
                opacity: (1 - shrinkOffset / expandedHeight),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: info.image!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    Container(
                      height: 300,
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
            info: info,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Opacity(
              opacity: (1 - shrinkOffset / expandedHeight),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          "${info.spoonacularScore?.toStringAsFixed(1)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  FavoriteButton(info: info),
                ],
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
    Key? key,
    required this.expandedHeight,
    required this.shrinkOffset,
    required this.info,
  }) : super(key: key);

  final double expandedHeight;
  final double shrinkOffset;
  final Recipe info;

  @override
  _AppBarWidgetState createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
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
            // padding: EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () async {},
          icon: const Icon(CupertinoIcons.share, color: Colors.black),
        )
      ],
      title: Opacity(
        opacity: (0 + widget.shrinkOffset / widget.expandedHeight),
        child: Text(
          "YumHub",
          style: GoogleFonts.chivo(
            textStyle: const TextStyle(
              fontSize: 25.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
