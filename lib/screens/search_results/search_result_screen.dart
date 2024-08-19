import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/models/search_results.dart';
import 'package:food_recipe_app/screens/recipe_info/bloc/recipe_info_bloc.dart';
import 'package:food_recipe_app/screens/recipe_info/recipe_info_screen.dart';
import 'package:food_recipe_app/screens/search_results/bloc/search_result_bloc.dart';
import 'package:food_recipe_app/screens/search_results/bloc/search_result_event.dart';
import 'package:food_recipe_app/screens/search_results/bloc/search_result_state.dart';
import 'package:food_recipe_app/widgets/loading_widget.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../custom_dialogs/error_widget.dart';

class SearchResults extends StatefulWidget {
  final String id;
  const SearchResults({super.key, required this.id});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  late final SearchResultsBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<SearchResultsBloc>(context);
    bloc.add(LoadSearchResults(name: widget.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.orange[800]),
        title: Text(
          "YumHub",
          style: GoogleFonts.chivo(
            textStyle: TextStyle(
              fontSize: 28.0,
              color: Colors.orange[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
          child: BlocBuilder<SearchResultsBloc, SearchResultsState>(
            builder: (context, state) {
              if (state is SearchResultsLoading) {
                return const Center(child: LoadingWidget());
              } else if (state is SearchResultsSuccess) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Results for "${widget.id}"',
                        style: GoogleFonts.chivo(
                          textStyle: TextStyle(
                            fontSize: 20.0,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: state.results.length,
                          itemBuilder: (context, index) {
                            return SearchResultItem(
                                result: state.results[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is SearchResultsError) {
                return ErrorDisplay(
                  errorMessage: state.errorMessage
                          .contains('API call limit reached')
                      ? "You've reached the daily limit of 150 API calls. Please try again tomorrow or upgrade your plan."
                      : state.errorMessage,
                );
              } else {
                return const Center(
                  child: Text("Unexpected state. Please restart the app."),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class SearchResultItem extends StatelessWidget {
  final SearchResult result;

  const SearchResultItem({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => RecipeInfoBloc(),
              child: RecipeInfo(id: result.id),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: CachedNetworkImage(
                imageUrl: result.image,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.orange[100],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.orange[100],
                  child: const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                result.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.chivo(
                  textStyle: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
