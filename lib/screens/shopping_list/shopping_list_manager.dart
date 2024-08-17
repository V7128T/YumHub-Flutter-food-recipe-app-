import 'package:firebase_database/firebase_database.dart';
import 'package:food_recipe_app/screens/shopping_list/merge_shopping_list.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:food_recipe_app/models/shopping_list_item.dart';
import 'package:food_recipe_app/models/store_product.dart';

class ShoppingListManager {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Product> _products = [];

  List<MergedShoppingListItem> mergeShoppingList(
      List<ShoppingListItem> shoppingList) {
    Map<String, MergedShoppingListItem> mergedItems = {};

    for (var item in shoppingList) {
      final product = findProductByName(item.name);
      if (product != null) {
        if (mergedItems.containsKey(product.name)) {
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
    return shoppingList.where((item) {
      final product = findProductByName(item.name);
      return product == null || product.stock == 0;
    }).toList();
  }

  Future<void> loadProducts() async {
    try {
      final snapshot = await _database.child('products').once();
      final event = snapshot.snapshot;

      if (event.value != null) {
        if (event.value is List) {
          final productsData = event.value as List<dynamic>;
          _products = productsData
              .map((product) {
                if (product is Map<dynamic, dynamic>) {
                  try {
                    return Product.fromJson(Map<String, dynamic>.from(product));
                  } catch (e) {
                    print('Error parsing product: $e');
                    return null;
                  }
                }
                return null;
              })
              .whereType<Product>()
              .toList();
        } else if (event.value is Map) {
          final productsData = event.value as Map<dynamic, dynamic>;
          _products = productsData.entries
              .map((entry) {
                if (entry.value is Map<dynamic, dynamic>) {
                  try {
                    return Product.fromJson(
                        Map<String, dynamic>.from(entry.value));
                  } catch (e) {
                    print('Error parsing product: $e');
                    return null;
                  }
                }
                return null;
              })
              .whereType<Product>()
              .toList();
        } else {
          print('Unexpected data structure for products');
          _products = [];
        }
      } else {
        _products = [];
      }
      print('Loaded ${_products.length} products');
    } catch (e) {
      print('Error loading products: $e');
      _products = [];
    }
  }

  Future<void> addToShoppingList(String userId, ShoppingListItem item) async {
    final userShoppingListRef = _database.child('users/$userId/shopping_list');

    // Check if the item already exists
    final snapshot = await userShoppingListRef
        .orderByChild('name')
        .equalTo(item.name)
        .once();
    final event = snapshot.snapshot;

    if (event.value != null) {
      // Update the existing item
      final existingItem = (event.value as Map<dynamic, dynamic>).entries.first;
      final currentQuantity = existingItem.value['quantity'] ?? 1;
      await userShoppingListRef
          .child(existingItem.key)
          .update({'quantity': currentQuantity + 1});
    } else {
      // Add new item
      await userShoppingListRef.push().set(item.toJson());
    }
  }

  Future<List<ShoppingListItem>> getShoppingList(String userId) async {
    try {
      final snapshot =
          await _database.child('users/$userId/shopping_list').once();
      final event = snapshot.snapshot;

      if (event.value != null) {
        final shoppingListData = event.value as Map<dynamic, dynamic>;
        return shoppingListData.entries
            .map((entry) {
              try {
                return ShoppingListItem.fromJson(
                    Map<String, dynamic>.from(entry.value));
              } catch (e) {
                print('Error parsing item ${entry.key}: $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<ShoppingListItem>()
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching shopping list: $e');
      return [];
    }
  }

  Future<void> updateItemQuantity(
      String userId, String itemId, int newQuantity) async {
    try {
      await _database.child('users/$userId/shopping_list/$itemId').update({
        'quantity': newQuantity,
      });
      print('Updated quantity for item $itemId to $newQuantity');
    } catch (e) {
      print('Error updating item quantity: $e');
      throw Exception('Failed to update item quantity');
    }
  }

  Future<void> removeFromShoppingList(String userId, String itemId) async {
    await _database.child('users/$userId/shopping_list/$itemId').remove();
  }

  Future<void> clearShoppingList(String userId) async {
    await _database.child('users/$userId/shopping_list').remove();
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

  Future<void> updateItemPurchasedStatus(
      String userId, String itemId, bool purchased) async {
    await _database
        .child('users/$userId/shopping_list/$itemId')
        .update({'purchased': purchased});
  }

  Future<void> updateProductStock(String productName, int newStock) async {
    try {
      // Get all products
      final snapshot = await _database.child('products').once();
      final event = snapshot.snapshot;

      if (event.value != null && event.value is List) {
        final productsData = event.value as List<dynamic>;

        // Find the index of the product with the matching name
        final productIndex = productsData.indexWhere((product) =>
            product is Map<dynamic, dynamic> && product['name'] == productName);

        if (productIndex != -1) {
          // Update the stock of the found product
          await _database.child('products/$productIndex/stock').set(newStock);

          // Update the local product list
          if (productIndex < _products.length) {
            _products[productIndex] =
                _products[productIndex].copyWith(stock: newStock);
          }

          print('Updated stock for product $productName to $newStock');
        } else {
          throw Exception('Product not found: $productName');
        }
      } else {
        throw Exception('Unexpected data structure for products');
      }
    } catch (e) {
      print('Error updating product stock: $e');
      throw Exception('Failed to update product stock: $e');
    }
  }
}
