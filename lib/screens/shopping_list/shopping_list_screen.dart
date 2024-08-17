import 'package:flutter/material.dart';
import 'package:food_recipe_app/models/shopping_list_item.dart';
import 'package:food_recipe_app/screens/shopping_list/merge_shopping_list.dart';
import 'package:food_recipe_app/screens/shopping_list/shopping_list_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

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
        print('Fetched shopping list: ${list.length} items');

        final unavailable = _shoppingListManager.getUnavailableItems(list);
        print('Unavailable items: ${unavailable.length}');

        final availableItems = list.where((item) {
          final product = _shoppingListManager.findProductByName(item.name);
          return product != null && product.stock > 0;
        }).toList();

        final merged = _shoppingListManager.mergeShoppingList(availableItems);
        print('Merged shopping list: ${merged.length} items');

        setState(() {
          shoppingList = list;
          unavailableItems = unavailable;
          mergedShoppingList = merged;
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
    final inStock = item.product.stock > 0;

    if (!inStock) {
      return const SizedBox.shrink(); // Don't display out-of-stock items
    }

    final canIncrease = item.quantity < item.product.stock;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: item.quantity > 0 ? 1.0 : 0.0,
      child: ListTile(
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                '${item.quantity}',
                key: ValueKey<int>(item.quantity),
                style: GoogleFonts.chivo(
                  textStyle:
                      const TextStyle(color: Colors.black, fontSize: 16.0),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: canIncrease ? () => _updateQuantity(item, 1) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnavailableItem(ShoppingListItem item) {
    final product = _shoppingListManager.findProductByName(item.name);
    final message = product == null ? 'Not available in store' : 'Out of stock';

    return ListTile(
      title: Text(
        '${item.name} ($message)',
        style: GoogleFonts.chivo(color: Colors.red),
      ),
      subtitle: Text('${item.amount} ${item.unit}', style: GoogleFonts.chivo()),
    );
  }

  Future<void> _updateQuantity(MergedShoppingListItem item, int change) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newQuantity = item.quantity + change;
      print(
          'Updating quantity for ${item.product.name} from ${item.quantity} to $newQuantity');
      if (newQuantity > 0) {
        // Update UI immediately
        setState(() {
          item.quantity = newQuantity;
          for (var originalItem in item.originalItems) {
            originalItem.quantity = newQuantity;
          }
        });

        // Update database
        for (var originalItem in item.originalItems) {
          await _shoppingListManager.updateItemQuantity(
            user.uid,
            originalItem.id,
            newQuantity,
          );
        }
      } else {
        // Remove item if quantity is 0 or less
        setState(() {
          mergedShoppingList.remove(item);
          shoppingList.removeWhere(
              (shoppingItem) => item.originalItems.contains(shoppingItem));
        });

        // Remove from database
        for (var originalItem in item.originalItems) {
          await _shoppingListManager.removeFromShoppingList(
            user.uid,
            originalItem.id,
          );
        }
      }
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
              onPressed: () async {
                Navigator.of(context).pop();
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  try {
                    List<Map<String, dynamic>> purchasedItems = [];
                    double totalAmount = 0;

                    for (var item in mergedShoppingList) {
                      final newStock = item.product.stock - item.quantity;
                      if (newStock < 0) {
                        throw Exception(
                            'Not enough stock for ${item.product.name}');
                      }
                      await _shoppingListManager.updateProductStock(
                          item.product.name, newStock);
                      print(
                          'Updated stock for ${item.product.name} to $newStock');

                      // Add item to the purchased items list
                      purchasedItems.add({
                        'name': item.product.name,
                        'quantity': item.quantity,
                        'price': item.product.price,
                        'total': item.quantity * item.product.price,
                      });
                      totalAmount += item.quantity * item.product.price;
                    }

                    await _shoppingListManager.clearShoppingList(user.uid);
                    await _loadShoppingList();

                    // Generate and show receipt
                    _showReceipt(purchasedItems, totalAmount);
                  } catch (e) {
                    print('Error during purchase: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Purchase failed: $e',
                              style: GoogleFonts.chivo())),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showReceipt(
      List<Map<String, dynamic>> items, double totalAmount) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Receipt',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Item',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Quantity',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Price',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  ...items
                      .map((item) => pw.TableRow(
                            children: [
                              pw.Text(item['name']),
                              pw.Text(item['quantity'].toString()),
                              pw.Text('RM ${item['price'].toStringAsFixed(2)}'),
                              pw.Text('RM ${item['total'].toStringAsFixed(2)}'),
                            ],
                          ))
                      .toList(),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Total Amount: RM ${totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/receipt.pdf');
    await file.writeAsBytes(await pdf.save());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Purchase Completed',
              style: GoogleFonts.chivo(fontWeight: FontWeight.bold)),
          content: Text(
              'Your purchase was successful. Would you like to share the receipt?',
              style: GoogleFonts.chivo()),
          actions: <Widget>[
            TextButton(
              child: Text('No', style: GoogleFonts.chivo()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child:
                  Text('Share', style: GoogleFonts.chivo(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                Share.shareXFiles(
                  [XFile(file.path)],
                  subject: 'Purchase Receipt',
                  text: 'Here is my purchase receipt',
                );
              },
            ),
          ],
        );
      },
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
                      ...unavailableItems.map(_buildUnavailableItem),
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
          onPressed:
              mergedShoppingList.isEmpty ? null : _showPurchaseConfirmation,
          child: Text('Purchase',
              style: GoogleFonts.chivo(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }
}
