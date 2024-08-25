import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/animation/animation.dart';
import 'package:food_recipe_app/models/auto_complete.dart';
import 'package:food_recipe_app/screens/home_screen/widgets/horizontal_list.dart';
import 'package:food_recipe_app/screens/recipe_info/bloc/recipe_info_bloc.dart';
import 'package:food_recipe_app/screens/recipe_info/recipe_info_screen.dart';
import 'package:food_recipe_app/screens/search_page/cubit/search_page_cubit.dart';
import 'package:food_recipe_app/screens/search_page/cubit/search_page_state.dart';
import 'package:food_recipe_app/screens/search_results/bloc/search_result_bloc.dart';
import 'package:food_recipe_app/screens/search_results/search_result_screen.dart';
import 'package:food_recipe_app/widgets/loading_widget.dart';
import 'package:food_recipe_app/validator/url_validator.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_recipe_app/screens/authentication_screen/email_signup_page.dart';
import 'package:food_recipe_app/main.dart';
import 'package:food_recipe_app/repo/get_recipe_by_ingredients.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../custom_colors/app_colors.dart';
import '../../models/recipe.dart';

String capitalize(String s) =>
    s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final SearchPageCubit _searchPageCubit;
  late final TextEditingController _searchController;
  bool _isAdvancedSearchEnabled = false;
  bool _isVideoSearchEnabled = false;

  @override
  void initState() {
    super.initState();
    _searchPageCubit = SearchPageCubit(RecipeRepository());
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isAnonymous = user?.isAnonymous ?? true;

    return BlocProvider(
      create: (_) => _searchPageCubit,
      child: BlocListener<SearchPageCubit, SearchPageState>(
        listener: (context, state) {
          if (_searchController.text != state.searchText) {
            _searchController.text = state.searchText;
            _searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: _searchController.text.length),
            );
          }
        },
        child: BlocBuilder<SearchPageCubit, SearchPageState>(
          builder: (context, state) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[50]!, Colors.orange[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SafeArea(
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          backgroundColor: Colors.transparent,
                          floating: true,
                          pinned: true,
                          title: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: _isVideoSearchEnabled
                                        ? "Search recipe videos"
                                        : _isAdvancedSearchEnabled
                                            ? "Enter ingredients, separated by commas"
                                            : "Search recipe name",
                                    hintStyle: GoogleFonts.chivo(
                                      textStyle: const TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.search,
                                          color: AppColors.secFont),
                                      onPressed: () {
                                        _searchPageCubit.submitSearch();
                                      },
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor:
                                        const Color.fromARGB(64, 150, 107, 33),
                                  ),
                                  onChanged: (value) {
                                    _searchPageCubit.textChange(value);
                                  },
                                  onSubmitted: (v) {
                                    if (isAnonymous) {
                                      showGuestOverlay(context);
                                    } else {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => BlocProvider(
                                            create: (context) =>
                                                SearchResultsBloc(),
                                            child: SearchResults(
                                              id: v,
                                              searchMode: _isVideoSearchEnabled
                                                  ? SearchMode.videos
                                                  : _isAdvancedSearchEnabled
                                                      ? SearchMode.ingredients
                                                      : SearchMode.regular,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.filter_alt,
                                    color: AppColors.secFont),
                                onPressed: () => _showFilterDrawer(context),
                              ),
                            ],
                          ),
                        ),
                        if (_isAdvancedSearchEnabled)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                spacing: 8.0,
                                children: state.ingredients
                                    .map((ingredient) => Chip(
                                          label: Text(ingredient),
                                          onDeleted: () {
                                            _searchPageCubit
                                                .removeIngredient(ingredient);
                                          },
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        if (isAnonymous)
                          SliverFillRemaining(
                            child: _buildAnonymousContent(context),
                          )
                        else if (state.status == Status.success)
                          _isVideoSearchEnabled
                              ? SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      return _buildVideoItem(
                                          state.videos[index]);
                                    },
                                    childCount: state.videos.length,
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      return SearchAutoCompleteTile(
                                          list: state.searchList[index]);
                                    },
                                    childCount: state.searchList.length,
                                  ),
                                )
                        else if (state.status == Status.loading)
                          const SliverFillRemaining(
                            child: Center(child: LoadingWidget()),
                          )
                        else
                          SliverToBoxAdapter(
                            child: _buildDefaultContent(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnonymousContent(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(child: _buildDefaultContent()),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'You are logged in as a guest.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        showGuestOverlay(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Create an Account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
          child: Text(
            "Most Searched By People",
            style: GoogleFonts.playfairDisplay(
              textStyle: const TextStyle(
                fontSize: 20.0,
                color: AppColors.secFont,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: Wrap(
            alignment: WrapAlignment.start,
            children: [
              ChipWidget("Baking"),
              ChipWidget("Vegetarian"),
              ChipWidget("Sauces"),
              ChipWidget("Meat"),
              ChipWidget("Turkey"),
              ChipWidget("Chicken"),
              ChipWidget("Sausages"),
              ChipWidget("Mince"),
              ChipWidget("Burgers"),
              ChipWidget("Pasta"),
              ChipWidget("Noodles"),
              ChipWidget("Pizza"),
              ChipWidget("Soups"),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
          child: Text(
            "More Categories",
            style: GoogleFonts.playfairDisplay(
              textStyle: const TextStyle(
                fontSize: 20.0,
                color: AppColors.secFont,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const CategoryTile(
            text: "Main course",
            image:
                "https://images.unsplash.com/photo-1559847844-5315695dadae?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=740&q=80"),
        const CategoryTile(
            text: "Side-dish",
            image:
                "https://images.unsplash.com/photo-1534938665420-4193effeacc4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=751&q=80"),
        const CategoryTile(
            text: "Dessert",
            image:
                "https://images.unsplash.com/photo-1587314168485-3236d6710814?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=670&q=80"),
        const CategoryTile(
            text: "Appetizer",
            image:
                "https://images.unsplash.com/photo-1541529086526-db283c563270?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80"),
        const CategoryTile(
          text: "Salad",
          image:
              "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80",
        ),
        const CategoryTile(
          text: "Bread",
          image:
              "https://images.unsplash.com/photo-1509440159596-0249088772ff?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=752&q=80",
        ),
        const CategoryTile(
          text: "Breakfast",
          image:
              "https://images.unsplash.com/photo-1525351484163-7529414344d8?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80",
        ),
        const CategoryTile(
          text: "Soup",
          image:
              "https://images.unsplash.com/photo-1547592166-23ac45744acd?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=751&q=80",
        ),
        const CategoryTile(
          text: "Beverage",
          image:
              "https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
        ),
        const CategoryTile(
          text: "Sauce",
          image:
              "https://images.unsplash.com/photo-1472476443507-c7a5948772fc?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
        ),
        const CategoryTile(
          text: "Marinade",
          image:
              "https://images.unsplash.com/photo-1598511757337-fe2cafc31ba0?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
        ),
        const CategoryTile(
          text: "Fingerfood",
          image:
              "https://images.unsplash.com/photo-1605333396915-47ed6b68a00e?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
        ),
        const CategoryTile(
          text: "Snack",
          image:
              "https://images.unsplash.com/photo-1599490659213-e2b9527bd087?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
        ),
        const CategoryTile(
          text: "Drink",
          image:
              "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=334&q=80",
        ),
      ],
    );
  }

  Widget _buildVideoItem(RecipeVideo video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: video.thumbnail,
          width: 100,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(
          capitalize(video.title),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.montserrat(
            textStyle: const TextStyle(
              fontSize: 15.0,
              color: AppColors.secFont,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        subtitle: Text(
          video.views != null
              ? '${video.views} views'
              : 'Tap to watch on YouTube',
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        trailing: video.rating != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    video.rating!.toStringAsFixed(1),
                    style: GoogleFonts.montserrat(fontSize: 12),
                  ),
                ],
              )
            : null,
        onTap: () async {
          final youtubeUrl =
              Uri.parse('https://www.youtube.com/watch?v=${video.youTubeId}');
          if (await canLaunchUrl(youtubeUrl)) {
            await launchUrl(youtubeUrl);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open YouTube video')),
            );
          }
        },
      ),
    );
  }

  void _showFilterDrawer(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    const Color backgroundColor = Colors.white;
    const Color textColor = Colors.black87;
    final Color inactiveColor = Colors.grey[400]!;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(-3, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Filter Options',
                              style: GoogleFonts.poppins(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: primaryColor),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Search Mode',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildFilterOption(
                                        'Normal',
                                        !_isAdvancedSearchEnabled &&
                                            !_isVideoSearchEnabled,
                                        () {
                                          setState(() {
                                            _isAdvancedSearchEnabled = false;
                                            _isVideoSearchEnabled = false;
                                          });
                                          _searchPageCubit.resetSearch();
                                          Navigator.of(context).pop();
                                        },
                                        primaryColor,
                                        inactiveColor,
                                      ),
                                      _buildFilterOption(
                                        'Ingredients',
                                        _isAdvancedSearchEnabled,
                                        () {
                                          setState(() {
                                            _isAdvancedSearchEnabled = true;
                                            _isVideoSearchEnabled = false;
                                          });
                                          _searchPageCubit
                                              .toggleAdvancedSearch();
                                          _searchPageCubit.emit(_searchPageCubit
                                              .state
                                              .copyWith(ingredients: []));
                                          Navigator.of(context).pop();
                                        },
                                        primaryColor,
                                        inactiveColor,
                                      ),
                                      _buildFilterOption(
                                        'Videos',
                                        _isVideoSearchEnabled,
                                        () {
                                          setState(() {
                                            _isAdvancedSearchEnabled = false;
                                            _isVideoSearchEnabled = true;
                                          });
                                          _searchPageCubit.toggleVideoSearch();
                                          Navigator.of(context).pop();
                                        },
                                        primaryColor,
                                        inactiveColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, bool isActive, VoidCallback onTap,
      Color activeColor, Color inactiveColor) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16.0,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            if (isActive) Icon(Icons.check_circle, color: activeColor),
          ],
        ),
      ),
    );
  }
}

void showGuestOverlay(BuildContext context) {
  showMaterialModalBottomSheet(
    context: context,
    builder: (context) => SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'You are currently logged in as a guest.',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'To access all features and personalize your experience, please create an account.',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Future.delayed(
                  const Duration(seconds: 1),
                  () {
                    navKey.currentState?.pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const EmailSignUp()),
                      (route) => false,
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Create an Account',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class CategoryTile extends StatelessWidget {
  final String text;
  final String image;
  const CategoryTile({super.key, required this.text, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: DelayedDisplay(
        delay: const Duration(microseconds: 600),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => SearchResultsBloc(),
                        child: SearchResults(
                          id: text,
                          searchMode: SearchMode.regular,
                        ),
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 80,
                      child: CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          text,
                          style: GoogleFonts.playfairDisplay(
                            textStyle: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SearchAutoCompleteTile extends StatefulWidget {
  final SearchAutoComplete list;
  const SearchAutoCompleteTile({
    super.key,
    required this.list,
  });

  @override
  _SearchAutoCompleteTileState createState() => _SearchAutoCompleteTileState();
}

class _SearchAutoCompleteTileState extends State<SearchAutoCompleteTile> {
  late Future<bool> _validationFuture;

  @override
  void initState() {
    super.initState();
    _validationFuture = validateURL(widget.list.image);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              offset: Offset(-2, -2),
              blurRadius: 12,
              color: Color.fromRGBO(0, 0, 0, 0.05),
            ),
            BoxShadow(
              offset: Offset(2, 2),
              blurRadius: 5,
              color: Color.fromRGBO(0, 0, 0, 0.10),
            )
          ],
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: FutureBuilder<bool>(
          future: _validationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                strokeWidth: 0.2,
                strokeAlign: 0.0,
                color: Colors.orange,
              );
            } else if (snapshot.hasError) {
              return const Icon(Icons.error);
            } else if (snapshot.hasData && snapshot.data!) {
              // if the URL is valid, then proceed to load the image
              return ListTile(
                onTap: () {
                  // Check if the image URL is valid before displaying the image
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => RecipeInfoBloc(),
                        child: RecipeInfo(
                          id: widget.list.id,
                        ),
                      ),
                    ),
                  );
                },
                leading: Container(
                  width: 100,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade600,
                  ),
                  child: CachedNetworkImage(
                    memCacheWidth: 262,
                    memCacheHeight: 147,
                    imageUrl: widget.list.image,
                    fit: BoxFit.cover,
                    cacheManager: CacheManager(
                      Config(
                        'customCacheKey',
                        maxNrOfCacheObjects: 100,
                        stalePeriod: const Duration(minutes: 5),
                      ),
                    ),
                    progressIndicatorBuilder: (context, url,
                            imgDownloadProgress) =>
                        CircularProgressIndicator(
                            value: imgDownloadProgress.progress,
                            strokeWidth: 0.2,
                            strokeAlign: 0.0,
                            color: Colors.orange),
                    errorWidget: (context, url, error) {
                      return const Icon(Icons.error); // Display erorr icon
                    },
                  ),
                ),
                title: Text(
                  capitalize(widget.list.name),
                  style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                      fontSize: 15.0,
                      color: AppColors.secFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            } else {
              // Handle invalid URL
              return ListTile(
                title: Text(
                  "Image Failed to Load.",
                  style: GoogleFonts.workSans(
                    textStyle: const TextStyle(
                      fontSize: 15.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
