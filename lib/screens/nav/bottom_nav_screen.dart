import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/screens/home_screen/bloc/homerecipe_bloc.dart';
import 'package:food_recipe_app/screens/home_screen/home_screen.dart';
import 'package:food_recipe_app/screens/more/more.dart';
import 'package:food_recipe_app/screens/profile_screen/bloc/profile_bloc.dart';
import 'package:food_recipe_app/screens/profile_screen/bloc/profile_event.dart';
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

  final List<Widget> _widgetOptions = <Widget>[
    BlocProvider(
      create: (context) => HomeRecipesBloc(),
      child: const HomeRecipeScreen(),
    ),
    BlocProvider(
      create: (context) => SearchPageCubit(_recipeRepository),
      child: const SearchPage(),
    ),
    const IngredientManagerPage(),
    const More(),
    BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfile()),
      child: const ProfilePage(),
    ),
  ];

  ///Bottom Navigation Bar Childrens
  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        inactiveColorPrimary: Colors.grey.shade600,
        iconSize: 20,
        icon: const Icon(
          CupertinoIcons.home,
        ),
        activeColorPrimary: Colors.redAccent,
        title: ("Home"),
      ),
      PersistentBottomNavBarItem(
        inactiveColorPrimary: Colors.grey.shade600,
        iconSize: 20,
        icon: const Icon(
          CupertinoIcons.search,
        ),
        activeColorPrimary: Colors.redAccent,
        title: ("Search"),
      ),
      PersistentBottomNavBarItem(
        inactiveColorPrimary: Colors.grey.shade600,
        icon: const Icon(
          Icons.local_grocery_store,
        ),
        iconSize: 20,
        activeColorPrimary: Colors.redAccent,
        title: ("Ingredient"),
      ),
      PersistentBottomNavBarItem(
        inactiveColorPrimary: Colors.grey.shade600,
        icon: const Icon(
          Icons.list,
        ),
        iconSize: 20,
        activeColorPrimary: Colors.redAccent,
        title: ("More"),
      ),
      PersistentBottomNavBarItem(
        inactiveColorPrimary: Colors.grey.shade600,
        icon: const Icon(
          Icons.people,
        ),
        iconSize: 20,
        activeColorPrimary: Colors.redAccent,
        title: ("Profile"),
      ),
    ];
  }

  @override
  void initState() {
    ///Initial Passing index as 0
    _controller = PersistentTabController(initialIndex: 0);
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
        this.context,
        controller: _controller,
        screens: _widgetOptions,
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        hideNavigationBarWhenKeyboardShows: true,
        popAllScreensOnTapOfSelectedTab: true,
        navBarStyle: NavBarStyle.style6,
        screenTransitionAnimation: const ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
      ),
    );
  }
}
