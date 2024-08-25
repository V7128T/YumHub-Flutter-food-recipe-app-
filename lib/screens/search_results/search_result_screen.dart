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
import 'package:url_launcher/url_launcher.dart';
import '../../custom_colors/app_colors.dart';
import '../../custom_dialogs/error_widget.dart';
import '../search_page/cubit/search_page_state.dart';

class SearchResults extends StatefulWidget {
  final String id;
  final SearchMode searchMode;
  const SearchResults({super.key, required this.id, required this.searchMode});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  late final SearchResultsBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<SearchResultsBloc>(context);
    bloc.add(LoadSearchResults(name: widget.id, mode: widget.searchMode));
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
          style: GoogleFonts.playfairDisplay(
            textStyle: const TextStyle(
              fontSize: 28.0,
              color: AppColors.secFont,
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
                return _buildSearchResultsLayout(state.results);
              } else if (state is SearchResultsError) {
                return ErrorDisplay(
                  errorMessage: state.errorMessage.contains(
                          'DioException [bad response]: This exception was thrown because the response has a status code of 402 and RequestOptions.validateStatus was configured to throw for this status code.')
                      ? "You've reached the daily limit of 150 API calls. Please try again tomorrow or upgrade your plan."
                      : state.errorMessage,
                );
              } else if (state is SearchResultsEmpty) {
                return Center(
                  child: Text(
                    _getEmptyMessage(),
                    style: GoogleFonts.chivo(
                      textStyle: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
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

  String _getEmptyMessage() {
    switch (widget.searchMode) {
      case SearchMode.regular:
        return "No recipes found for '${widget.id}'. Try a different search term.";
      case SearchMode.ingredients:
        return "No recipes found with the ingredients: ${widget.id}. Try different ingredients or combinations.";
      case SearchMode.videos:
        return "No recipe videos found for '${widget.id}'. Try a different search term.";
    }
  }

  Widget _buildSearchResultsLayout(List<SearchResult> results) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Results',
                  style: GoogleFonts.playfairDisplay(
                    textStyle: TextStyle(
                      fontSize: 24.0,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'for "${widget.id}"',
                  style: GoogleFonts.playfairDisplay(
                    textStyle: TextStyle(
                      fontSize: 18.0,
                      color: Theme.of(context).primaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${results.length} ${widget.searchMode == SearchMode.videos ? 'videos' : 'recipes'} found',
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: widget.searchMode == SearchMode.videos
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildVideoItem(results[index]),
                    childCount: results.length,
                  ),
                )
              : SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return SearchResultItem(result: results[index]);
                    },
                    childCount: results.length,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildVideoItem(SearchResult video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: video.image,
          width: 100,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(
          video.name,
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
          final youtubeUrl = Uri.parse(
              'https://www.youtube.com/watch?v=${video.youTubeId ?? video.id}');
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to see details',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
