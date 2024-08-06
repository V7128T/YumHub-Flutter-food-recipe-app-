import 'package:food_recipe_app/models/shopping_list_item.dart';
import 'package:food_recipe_app/models/store_product.dart';

class MergedShoppingListItem {
  final Product product;
  double totalAmount;
  int quantity;
  final List<ShoppingListItem> originalItems;

  MergedShoppingListItem({
    required this.product,
    required this.totalAmount,
    required this.quantity,
    required this.originalItems,
  });
}
