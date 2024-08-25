import 'package:food_recipe_app/models/analyzed_instructions.dart';
import 'extended_ingredient.dart';

///Recipe Model
class Recipe {
  bool? vegetarian;
  bool? vegan;
  bool? glutenFree;
  bool? dairyFree;
  bool? veryHealthy;
  bool? cheap;
  bool? veryPopular;
  bool? sustainable;
  int? weightWatcherSmartPoints;
  String? gaps;
  bool? lowFodmap;
  int? aggregateLikes;
  double? spoonacularScore;
  double? healthScore;
  String? creditsText;
  String? license;
  String? sourceName;
  double? pricePerServing;
  List<ExtendedIngredient>? extendedIngredients;
  int? id;
  String? title;
  int? readyInMinutes;
  int? servings;
  String? sourceUrl;
  String? image;
  String? imageType;
  String? summary;
  List<dynamic>? cuisines;
  List<dynamic>? dishTypes;
  List<dynamic>? diets;
  List<dynamic>? occasions;
  final List<RecipeVideo>? videos;
  String? instructions;
  List<AnalyzedInstruction>? analyzedInstructions;
  dynamic originalId;
  String? spoonacularSourceUrl;
  DateTime? dateAdded;
  DateTime? dateRemoved;

  Recipe({
    this.vegetarian,
    this.vegan,
    this.glutenFree,
    this.dairyFree,
    this.veryHealthy,
    this.cheap,
    this.veryPopular,
    this.sustainable,
    this.weightWatcherSmartPoints,
    this.gaps,
    this.lowFodmap,
    this.aggregateLikes,
    this.spoonacularScore,
    this.healthScore,
    this.creditsText,
    this.license,
    this.sourceName,
    this.pricePerServing,
    this.extendedIngredients,
    this.id,
    this.title,
    this.readyInMinutes,
    this.servings,
    this.sourceUrl,
    this.image,
    this.imageType,
    this.summary,
    this.cuisines,
    this.dishTypes,
    this.diets,
    this.occasions,
    this.videos,
    this.instructions,
    this.analyzedInstructions,
    this.originalId,
    this.spoonacularSourceUrl,
    this.dateAdded,
    this.dateRemoved,
  });

  Recipe copyWith({
    bool? vegetarian,
    bool? vegan,
    bool? glutenFree,
    bool? dairyFree,
    bool? veryHealthy,
    bool? cheap,
    bool? veryPopular,
    bool? sustainable,
    int? weightWatcherSmartPoints,
    String? gaps,
    bool? lowFodmap,
    int? aggregateLikes,
    double? spoonacularScore,
    double? healthScore,
    String? creditsText,
    String? license,
    String? sourceName,
    double? pricePerServing,
    List<ExtendedIngredient>? extendedIngredients,
    int? id,
    String? title,
    int? readyInMinutes,
    int? servings,
    String? sourceUrl,
    String? image,
    String? imageType,
    String? summary,
    List<dynamic>? cuisines,
    List<dynamic>? dishTypes,
    List<dynamic>? diets,
    List<dynamic>? occasions,
    final List<RecipeVideo>? videos,
    String? instructions,
    List<AnalyzedInstruction>? analyzedInstructions,
    dynamic originalId,
    String? spoonacularSourceUrl,
    DateTime? dateAdded,
    DateTime? dateRemoved,
  }) {
    return Recipe(
      vegetarian: vegetarian ?? this.vegetarian,
      vegan: vegan ?? this.vegan,
      glutenFree: glutenFree ?? this.glutenFree,
      dairyFree: dairyFree ?? this.dairyFree,
      veryHealthy: veryHealthy ?? this.veryHealthy,
      cheap: cheap ?? this.cheap,
      veryPopular: veryPopular ?? this.veryPopular,
      sustainable: sustainable ?? this.sustainable,
      weightWatcherSmartPoints:
          weightWatcherSmartPoints ?? this.weightWatcherSmartPoints,
      gaps: gaps ?? this.gaps,
      lowFodmap: lowFodmap ?? this.lowFodmap,
      aggregateLikes: aggregateLikes ?? this.aggregateLikes,
      spoonacularScore: spoonacularScore ?? this.spoonacularScore,
      healthScore: healthScore ?? this.healthScore,
      creditsText: creditsText ?? this.creditsText,
      license: license ?? this.license,
      sourceName: sourceName ?? this.sourceName,
      pricePerServing: pricePerServing ?? this.pricePerServing,
      extendedIngredients: extendedIngredients ?? this.extendedIngredients,
      id: id ?? this.id,
      title: title ?? this.title,
      readyInMinutes: readyInMinutes ?? this.readyInMinutes,
      servings: servings ?? this.servings,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      image: image ?? this.image,
      imageType: imageType ?? this.imageType,
      summary: summary ?? this.summary,
      cuisines: cuisines ?? this.cuisines,
      dishTypes: dishTypes ?? this.dishTypes,
      diets: diets ?? this.diets,
      occasions: occasions ?? this.occasions,
      videos: videos ?? this.videos,
      instructions: instructions ?? this.instructions,
      analyzedInstructions: analyzedInstructions ?? this.analyzedInstructions,
      originalId: originalId ?? this.originalId,
      spoonacularSourceUrl: spoonacularSourceUrl ?? this.spoonacularSourceUrl,
      dateAdded: dateAdded ?? this.dateAdded,
      dateRemoved: dateRemoved ?? this.dateRemoved,
    );
  }

  factory Recipe.fromJson(json) => Recipe(
        vegetarian: json['vegetarian'] as bool?,
        vegan: json['vegan'] as bool?,
        glutenFree: json['glutenFree'] as bool?,
        dairyFree: json['dairyFree'] as bool?,
        veryHealthy: json['veryHealthy'] as bool?,
        cheap: json['cheap'] as bool?,
        veryPopular: json['veryPopular'] as bool?,
        sustainable: json['sustainable'] as bool?,
        weightWatcherSmartPoints: json['weightWatcherSmartPoints'] as int?,
        gaps: json['gaps'] as String?,
        lowFodmap: json['lowFodmap'] as bool?,
        aggregateLikes: json['aggregateLikes'] as int?,
        spoonacularScore: (json['spoonacularScore'] as num?)?.toDouble(),
        healthScore: (json['healthScore'] as num?)?.toDouble(),
        creditsText: json['creditsText'] as String?,
        license: json['license'] as String?,
        sourceName: json['sourceName'] as String?,
        pricePerServing: (json['pricePerServing'] as num?)?.toDouble(),
        extendedIngredients: (json['extendedIngredients'] as List<dynamic>?)
            ?.map((e) => ExtendedIngredient.fromJson(e))
            .toList(),
        id: json['id'],
        title: json['title'] as String?,
        readyInMinutes: json['readyInMinutes'] as int?,
        servings: json['servings'] as int?,
        sourceUrl: json['sourceUrl'] as String?,
        image: json['image'] as String?,
        imageType: json['imageType'] as String?,
        summary: json['summary'] as String?,
        cuisines: json['cuisines'] as List<dynamic>?,
        dishTypes: json['dishTypes'] as List<dynamic>?,
        diets: json['diets'] as List<dynamic>?,
        videos: json['videos'] != null
            ? (json['videos'] as List)
                .map((v) => RecipeVideo.fromJson(v as Map<String, dynamic>))
                .toList()
            : null,
        occasions: json['occasions'] as List<dynamic>?,
        instructions: json['instructions'] as String?,
        analyzedInstructions: (json['analyzedInstructions'] as List<dynamic>?)
            ?.map((e) => AnalyzedInstruction.fromJson(e))
            .toList(),
        originalId: json['originalId'] as dynamic,
        spoonacularSourceUrl: json['spoonacularSourceUrl'] as String?,
        dateAdded: json['dateAdded'] != null
            ? DateTime.parse(json['dateAdded'])
            : null,
        dateRemoved: json['dateRemoved'] != null
            ? DateTime.parse(json['dateRemoved'])
            : null,
      );

  toJson() => {
        'vegetarian': vegetarian,
        'vegan': vegan,
        'glutenFree': glutenFree,
        'dairyFree': dairyFree,
        'veryHealthy': veryHealthy,
        'cheap': cheap,
        'veryPopular': veryPopular,
        'sustainable': sustainable,
        'weightWatcherSmartPoints': weightWatcherSmartPoints,
        'gaps': gaps,
        'lowFodmap': lowFodmap,
        'aggregateLikes': aggregateLikes,
        'spoonacularScore': spoonacularScore,
        'healthScore': healthScore,
        'creditsText': creditsText,
        'license': license,
        'sourceName': sourceName,
        'pricePerServing': pricePerServing,
        'extendedIngredients':
            extendedIngredients?.map((e) => e.toJson()).toList(),
        'id': id,
        'title': title,
        'readyInMinutes': readyInMinutes,
        'servings': servings,
        'sourceUrl': sourceUrl,
        'image': image,
        'imageType': imageType,
        'summary': summary,
        'cuisines': cuisines,
        'dishTypes': dishTypes,
        'diets': diets,
        'videos': videos,
        'occasions': occasions,
        'instructions': instructions,
        'analyzedInstructions':
            analyzedInstructions?.map((e) => e.toJson()).toList(),
        'originalId': originalId,
        'spoonacularSourceUrl': spoonacularSourceUrl,
        'dateAdded': dateAdded?.toIso8601String(),
        'dateRemoved': dateRemoved?.toIso8601String(),
      };
}

class RecipeVideo {
  final String title;
  final int length;
  final double rating;
  final String shortTitle;
  final String thumbnail;
  final int views;
  final String youTubeId;

  RecipeVideo({
    required this.title,
    required this.length,
    required this.rating,
    required this.shortTitle,
    required this.thumbnail,
    required this.views,
    required this.youTubeId,
  });

  RecipeVideo copyWith({
    String? title,
    int? length,
    double? rating,
    String? shortTitle,
    String? thumbnail,
    int? views,
    String? youTubeId,
  }) {
    return RecipeVideo(
      title: title ?? this.title,
      length: length ?? this.length,
      rating: rating ?? this.rating,
      shortTitle: shortTitle ?? this.shortTitle,
      thumbnail: thumbnail ?? this.thumbnail,
      views: views ?? this.views,
      youTubeId: youTubeId ?? this.youTubeId,
    );
  }

  factory RecipeVideo.fromJson(Map<String, dynamic> json) {
    return RecipeVideo(
      title: json['title'],
      length: json['length'],
      rating: json['rating'].toDouble(),
      shortTitle: json['shortTitle'],
      thumbnail: json['thumbnail'],
      views: json['views'],
      youTubeId: json['youTubeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'length': length,
      'rating': rating,
      'shortTitle': shortTitle,
      'thumbnail': thumbnail,
      'views': views,
      'youTubeId': youTubeId,
    };
  }
}

class RecipeVideoList {
  final List<RecipeVideo> list;
  RecipeVideoList({
    required this.list,
  });

  factory RecipeVideoList.fromJson(List<dynamic> json) {
    return RecipeVideoList(
      list: json.map((data) => RecipeVideo.fromJson(data)).toList(),
    );
  }
}
