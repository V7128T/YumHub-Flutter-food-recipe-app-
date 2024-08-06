import 'package:flutter/material.dart';
import 'package:food_recipe_app/models/shopping_list_item.dart';
import 'package:food_recipe_app/screens/shopping_list/merge_shopping_list.dart';
import 'package:food_recipe_app/screens/shopping_list/shopping_list_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingListManager _shoppingListManager = ShoppingListManager();
  List<MergedShoppingListItem> mergedShoppingList = [];
  List<ShoppingListItem> shoppingList = [];
  List<ShoppingListItem> unavailableItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _shoppingListManager.loadProducts();
    await _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final list = await _shoppingListManager.getShoppingList(user.uid);
        setState(() {
          mergedShoppingList = _shoppingListManager.mergeShoppingList(list);
          unavailableItems = list
              .where((item) =>
                  _shoppingListManager.findProductByName(item.name) == null)
              .toList();
          shoppingList = list;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading shopping list: $e');
        setState(() {
          shoppingList = [];
          unavailableItems = [];
          mergedShoppingList = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load shopping list. Please try again.')),
        );
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildMergedShoppingListItem(MergedShoppingListItem item) {
    return ListTile(
      title: Text(item.product.name,
          style: GoogleFonts.chivo(fontWeight: FontWeight.w500)),
      subtitle: Text(
        'RM ${item.product.price.toStringAsFixed(2)} / ${item.product.packageSize} ${item.product.packageUnit}',
        style: GoogleFonts.chivo(),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.black),
            onPressed: () => _updateQuantity(item, -1),
          ),
          Text(
            '${item.quantity}',
            style: GoogleFonts.chivo(
              textStyle: const TextStyle(color: Colors.black, fontSize: 16.0),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () => _updateQuantity(item, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableItem(ShoppingListItem item) {
    return ListTile(
      title: Text(
        '${item.name} (not available in store)',
        style: GoogleFonts.chivo(color: Colors.red),
      ),
      subtitle: Text('${item.amount} ${item.unit}', style: GoogleFonts.chivo()),
    );
  }

  Future<void> _updateQuantity(MergedShoppingListItem item, int change) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newQuantity = item.quantity + change;
      if (newQuantity > 0) {
        // Update all original items
        for (var originalItem in item.originalItems) {
          await _shoppingListManager.updateItemQuantity(
              user.uid,
              originalItem.id,
              (originalItem.quantity * newQuantity) ~/ item.quantity);
        }
      } else {
        // Remove all original items
        for (var originalItem in item.originalItems) {
          await _shoppingListManager.removeFromShoppingList(
              user.uid, originalItem.id);
        }
      }
      await _loadShoppingList();
    }
  }

  Future<void> _updateIndividualQuantity(
      ShoppingListItem item, int change) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newQuantity = item.quantity + change;
      if (newQuantity > 0) {
        await _shoppingListManager.updateItemQuantity(
            user.uid, item.id, newQuantity);
      } else {
        await _shoppingListManager.removeFromShoppingList(user.uid, item.id);
      }
      await _loadShoppingList();
    }
  }

  Future<void> _clearShoppingList() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _shoppingListManager.clearShoppingList(user.uid);
      await _loadShoppingList();
    }
  }

  void _showPurchaseConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Purchase',
              style: GoogleFonts.chivo(fontWeight: FontWeight.bold)),
          content: Text('Do you want to proceed with the purchase?',
              style: GoogleFonts.chivo()),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.chivo()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Purchase',
                  style: GoogleFonts.chivo(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Purchase completed!',
                          style: GoogleFonts.chivo())),
                );
                _clearShoppingList();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildShoppingListItem(ShoppingListItem item) {
    final product = _shoppingListManager.findProductByName(item.name);
    if (product == null) {
      return ListTile(
        title: Text(
          '${item.name} (not available in store)',
          style: GoogleFonts.poppins(
              textStyle: const TextStyle(color: Colors.red)),
        ),
        subtitle:
            Text('${item.amount} ${item.unit}', style: GoogleFonts.poppins()),
      );
    }

    return ListTile(
      title: Text(product.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      subtitle: Text(
        'RM ${product.price.toStringAsFixed(2)} / ${product.packageSize} ${product.packageUnit}',
        style: GoogleFonts.poppins(),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.black),
            onPressed: () => _updateIndividualQuantity(item, -1),
          ),
          Text(
            '${item.quantity}',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(color: Colors.black, fontSize: 16.0),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () => _updateIndividualQuantity(item, 1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart',
            style: GoogleFonts.chivo(
              textStyle: const TextStyle(
                  fontSize: 25.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: shoppingList.isEmpty ? null : _clearShoppingList,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (mergedShoppingList.isEmpty && unavailableItems.isEmpty)
              ? Center(
                  child: Text(
                    'Your cart is empty',
                    style: GoogleFonts.chivo(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView(
                  children: [
                    if (mergedShoppingList.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Available Items',
                          style: GoogleFonts.chivo(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...mergedShoppingList.map(_buildMergedShoppingListItem),
                    ],
                    if (unavailableItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Unavailable Items',
                          style: GoogleFonts.chivo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ),
                      ...unavailableItems.map(_buildShoppingListItem),
                    ],
                  ],
                ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: shoppingList.isEmpty ? null : _showPurchaseConfirmation,
          child: Text('Purchase',
              style: GoogleFonts.chivo(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }
}
