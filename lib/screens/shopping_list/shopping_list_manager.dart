import 'dart:convert';
import 'package:food_recipe_app/screens/shopping_list/merge_shopping_list.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:food_recipe_app/models/shopping_list_item.dart';
import 'package:food_recipe_app/models/store_product.dart';

class ShoppingListManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _products = [];

  List<MergedShoppingListItem> mergeShoppingList(
      List<ShoppingListItem> shoppingList) {
    Map<String, MergedShoppingListItem> mergedItems = {};

    for (var item in shoppingList) {
      final product = findProductByName(item.name);
      if (product != null) {
        if (mergedItems.containsKey(product.name)) {
          mergedItems[product.name]!.totalAmount += item.amount;
          mergedItems[product.name]!.quantity += item.quantity;
          mergedItems[product.name]!.originalItems.add(item);
        } else {
          mergedItems[product.name] = MergedShoppingListItem(
            product: product,
            totalAmount: item.amount,
            quantity: item.quantity,
            originalItems: [item],
          );
        }
      }
    }

    return mergedItems.values.toList();
  }

  List<ShoppingListItem> getUnavailableItems(
      List<ShoppingListItem> shoppingList) {
    return shoppingList
        .where((item) => findProductByName(item.name) == null)
        .toList();
  }

  Future<void> loadProducts() async {
    final String response = await rootBundle.loadString('mock_api/db.json');
    final data = await json.decode(response);
    _products = (data['products'] as List)
        .map((product) => Product.fromJson(product))
        .toList();
  }

  Future<void> addToShoppingList(String userId, ShoppingListItem item) async {
    // Check if the item already exists
    final existingItem = await _firestore
        .collection('users')
        .doc(userId)
        .collection('shopping_list')
        .where('name', isEqualTo: item.name)
        .get();

    if (existingItem.docs.isNotEmpty) {
      // Update the existing item
      final docId = existingItem.docs.first.id;
      final currentQuantity = existingItem.docs.first.data()['quantity'] ?? 1;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('shopping_list')
          .doc(docId)
          .update({'quantity': currentQuantity + 1});
    } else {
      // Add new item
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('shopping_list')
          .doc(item.id)
          .set(item.toJson());
    }
  }

  Future<List<ShoppingListItem>> getShoppingList(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shopping_list')
          .get();
      return snapshot.docs
          .map((doc) {
            try {
              return ShoppingListItem.fromJson(doc.data());
            } catch (e) {
              print('Error parsing document ${doc.id}: $e');
              return null;
            }
          })
          .where((item) => item != null)
          .cast<ShoppingListItem>()
          .toList();
    } catch (e) {
      print('Error fetching shopping list: $e');
      return [];
    }
  }

  Product? findProductByName(String name) {
    final lowerName = name.toLowerCase();

    // Exact match
    final exactMatch = _products.cast<Product?>().firstWhere(
          (p) => p?.name.toLowerCase() == lowerName,
          orElse: () => null,
        );
    if (exactMatch != null) return exactMatch;

    // Alias match
    final aliasMatch = _products.cast<Product?>().firstWhere(
          (p) =>
              p?.aliases.any((alias) => alias.toLowerCase() == lowerName) ??
              false,
          orElse: () => null,
        );
    if (aliasMatch != null) return aliasMatch;

    // Fuzzy match
    final bestMatch = _products.map((p) {
      int score = ratio(p.name.toLowerCase(), lowerName);
      for (final alias in p.aliases) {
        final aliasScore = ratio(alias.toLowerCase(), lowerName);
        if (aliasScore > score) score = aliasScore;
      }
      return MapEntry(p, score);
    }).reduce((a, b) => a.value > b.value ? a : b);

    if (bestMatch.value > 80) {
      // You can adjust this threshold
      return bestMatch.key;
    }

    // Keyword match
    final keywords = lowerName.split(' ');
    final keywordMatch = _products.cast<Product?>().firstWhere(
          (p) => keywords.every((keyword) =>
              p?.name.toLowerCase().contains(keyword) ??
              false ||
                  p!.aliases
                      .any((alias) => alias.toLowerCase().contains(keyword))),
          orElse: () => null,
        );

    return keywordMatch;
  }

  Future<void> updateItemQuantity(
      String userId, String itemId, int newQuantity) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('shopping_list')
        .doc(itemId)
        .update({'quantity': newQuantity});
  }

  Future<void> removeFromShoppingList(String userId, String itemId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('shopping_list')
        .doc(itemId)
        .delete();
  }

  Future<void> clearShoppingList(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('shopping_list')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
