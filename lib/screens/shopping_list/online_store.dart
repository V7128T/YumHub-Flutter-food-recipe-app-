import 'package:firebase_database/firebase_database.dart';

class OnlineStore {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Product> products = [];
  List<ShoppingListItem> shoppingList = [];

  Future<void> loadData() async {
    final snapshot = await _database.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      products = (data['products'] as List)
          .map((p) => Product.fromJson(Map<String, dynamic>.from(p)))
          .toList();
      shoppingList = (data['shopping_list'] as List)
          .map((item) =>
              ShoppingListItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
  }

  Future<bool> purchaseItem(int productId, int quantity) async {
    final productIndex = products.indexWhere((p) => p.id == productId);
    if (productIndex != -1 && products[productIndex].stock >= quantity) {
      products[productIndex].stock -= quantity;
      await _database
          .child('products/$productIndex/stock')
          .set(products[productIndex].stock);
      return true;
    }
    return false;
  }

  Future<void> addToShoppingList(ShoppingListItem item) async {
    shoppingList.add(item);
    await _database
        .child('shopping_list')
        .set(shoppingList.map((item) => item.toJson()).toList());
  }

  Future<bool> purchaseShoppingList() async {
    bool allPurchased = true;
    for (var item in shoppingList) {
      if (!await purchaseItem(item.productId, item.quantity)) {
        allPurchased = false;
        break;
      }
    }
    if (allPurchased) {
      shoppingList.clear();
      await _database.child('shopping_list').set([]);
    }
    return allPurchased;
  }
}

class Product {
  final int id;
  final String name;
  final double price;
  final String unit;
  final int packageSize;
  final String packageUnit;
  int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.packageSize,
    required this.packageUnit,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      unit: json['unit'],
      packageSize: json['packageSize'],
      packageUnit: json['packageUnit'],
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'unit': unit,
      'packageSize': packageSize,
      'packageUnit': packageUnit,
      'stock': stock,
    };
  }
}

class ShoppingListItem {
  final int productId;
  final int quantity;

  ShoppingListItem({required this.productId, required this.quantity});

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      productId: json['productId'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
