import 'package:uuid/uuid.dart';
import 'measures.dart';

class ExtendedIngredient {
  final String _uniqueId;
  int? id;
  String? aisle;
  String? image;
  String? consistency;
  String? name;
  String? nameClean;
  String? recipeId;
  String? recipeName;
  String? original;
  String? originalString;
  String? originalName;
  double? amount;
  String? unit;
  List<dynamic>? meta;
  List<dynamic>? metaInformation;
  Measures? measures;
  double? convertedAmount;
  String? convertedUnit;

  ExtendedIngredient({
    String? uniqueId,
    this.id,
    this.aisle,
    this.image,
    this.consistency,
    this.name,
    this.nameClean,
    this.recipeId,
    this.recipeName,
    this.original,
    this.originalString,
    this.originalName,
    this.amount,
    this.unit,
    this.meta,
    this.metaInformation,
    this.measures,
    this.convertedAmount,
    this.convertedUnit,
  }) : _uniqueId = uniqueId ?? Uuid().v4();

  String get uniqueId => _uniqueId;

  factory ExtendedIngredient.fromJson(Map<String, dynamic> json) {
    return ExtendedIngredient(
      uniqueId: json['uniqueId'] as String?,
      id: json['id'] as int?,
      aisle: json['aisle'] as String?,
      image: json['image'] as String?,
      consistency: json['consistency'] as String?,
      name: json['name'] as String?,
      nameClean: json['nameClean'] as String?,
      original: json['original'] as String?,
      originalString: json['originalString'] as String?,
      originalName: json['originalName'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      meta: json['meta'] as List<dynamic>?,
      metaInformation: json['metaInformation'] as List<dynamic>?,
      measures:
          json['measures'] == null ? null : Measures.fromJson(json['measures']),
      convertedAmount: json['convertedAmount'],
      convertedUnit: json['convertedUnit'],
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'uniqueId': _uniqueId,
      'id': id,
      'aisle': aisle,
      'image': image,
      'consistency': consistency,
      'name': name,
      'nameClean': nameClean,
      'original': original,
      'originalString': originalString,
      'originalName': originalName,
      'amount': amount,
      'unit': unit,
      'meta': meta,
      'metaInformation': metaInformation,
      'measures': measures?.toJson(),
      'convertedAmount': convertedAmount,
      'convertedUnit': convertedUnit,
    };
    return json;
  }

  ExtendedIngredient copyWith({
    int? id,
    String? aisle,
    String? image,
    String? consistency,
    String? name,
    String? nameClean,
    String? recipeId,
    String? recipeName,
    String? original,
    String? originalString,
    String? originalName,
    double? amount,
    String? unit,
    List<dynamic>? meta,
    List<dynamic>? metaInformation,
    Measures? measures,
    double? convertedAmount,
    String? convertedUnit,
  }) {
    return ExtendedIngredient(
      uniqueId: _uniqueId,
      id: id ?? this.id,
      aisle: aisle ?? this.aisle,
      image: image ?? this.image,
      consistency: consistency ?? this.consistency,
      name: name ?? this.name,
      nameClean: nameClean ?? this.nameClean,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      original: original ?? this.original,
      originalString: originalString ?? this.originalString,
      originalName: originalName ?? this.originalName,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      meta: meta ?? this.meta,
      metaInformation: metaInformation ?? this.metaInformation,
      measures: measures ?? this.measures,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      convertedUnit: convertedUnit ?? this.convertedUnit,
    );
  }
}
