import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'measures.dart';

class ExtendedIngredient {
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

  ExtendedIngredient({
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
  });

  String get uniqueId {
    // Create a compound string of multiple properties
    final compoundString = '$id$name$amount$unit$recipeId';
    // Generate a SHA-256 hash of the compound string
    final bytes = utf8.encode(compoundString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  factory ExtendedIngredient.fromJson(Map<String, dynamic> json) {
    return ExtendedIngredient(
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
      measures: json['measures'] == null ? null : Measures.fromJson(json['measures']),
    );
  }

  Map<String, dynamic> toJson() => {
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
  };

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
  }) {
    return ExtendedIngredient(
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
    );
  }
}