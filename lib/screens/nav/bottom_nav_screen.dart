import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/custom_colors/app_colors.dart';
import 'package:food_recipe_app/screens/home_screen/bloc/homerecipe_bloc.dart';
import 'package:food_recipe_app/screens/home_screen/home_screen.dart';
import 'package:food_recipe_app/screens/more/more.dart';
import 'package:food_recipe_app/screens/profile_screen/profile_page.dart';
import 'package:food_recipe_app/screens/search_page/cubit/search_page_cubit.dart';
import 'package:food_recipe_app/screens/search_page/search_page_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:food_recipe_app/screens/ingredient_screen/ingredient_manager_screen.dart';
import 'package:food_recipe_app/repo/get_recipe_by_ingredients.dart';

class BottomNavView extends StatefulWidget {
  const BottomNavView({super.key});

  @override
  _BottomNavViewState createState() => _BottomNavViewState();
}

final _recipeRepository = RecipeRepository();

class _BottomNavViewState extends State<BottomNavView> {
  late PersistentTabController _controller;
  late UniqueKey _ingredientManagerKey, _profileKey;

  List<Widget> get _widgetOptions => [
        BlocProvider(
          create: (context) => HomeRecipesBloc(),
          child: const HomeRecipeScreen(),
        ),
        BlocProvider(
          create: (context) => SearchPageCubit(_recipeRepository),
          child: const SearchPage(),
        ),
        IngredientManagerPage(key: _ingredientManagerKey),
        const More(),
        ProfilePage(key: _profileKey),
      ];

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      _buildNavBarItem(CupertinoIcons.home, "Home"),
      _buildNavBarItem(CupertinoIcons.search, "Search"),
      _buildNavBarItem(Icons.local_grocery_store, "Ingredient"),
      _buildNavBarItem(Icons.list, "More"),
      _buildNavBarItem(Icons.people, "Profile"),
    ];
  }

  PersistentBottomNavBarItem _buildNavBarItem(IconData icon, String title) {
    return PersistentBottomNavBarItem(
      icon: Icon(icon),
      title: title,
      activeColorPrimary: Theme.of(context).primaryColor,
      inactiveColorPrimary: Colors.grey.shade600,
      iconSize: 24,
    );
  }

  void _handleTabChange() {
    if (_controller.index == 2) {
      // Index 2 is IngredientManagerPage
      // Force a refresh of IngredientManagerPage
      setState(() {
        _ingredientManagerKey = UniqueKey();
      });
    } else if (_controller.index == 4) {
      setState(() {
        _profileKey = UniqueKey();
      });
    }
  }

  @override
  void initState() {
    ///Initial Passing index as 0
    _controller = PersistentTabController(initialIndex: 0);
    _controller.addListener(_handleTabChange);
    _ingredientManagerKey = UniqueKey();
    _profileKey = UniqueKey();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: PersistentTabView(
      context,
      controller: _controller,
      screens: _widgetOptions,
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: AppColors.customPrimary,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      popAllScreensOnTapOfSelectedTab: true,
      navBarStyle: NavBarStyle.style6,
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
    ));
  }
}
