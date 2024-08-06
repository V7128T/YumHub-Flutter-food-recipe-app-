class ShoppingListItem {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final String? recipeId;
  final String? recipeName;
  final DateTime added;
  bool purchased;
  int quantity;

  ShoppingListItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    this.recipeId,
    this.recipeName,
    required this.added,
    this.purchased = false,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'unit': unit,
        'recipeId': recipeId,
        'recipeName': recipeName,
        'added': added.toIso8601String(),
        'purchased': purchased,
        'quantity': quantity,
      };

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) =>
      ShoppingListItem(
        id: json['id'] as String,
        name: json['name'],
        amount: json['amount'],
        unit: json['unit'],
        recipeId: json['recipeId'],
        recipeName: json['recipeName'],
        added: DateTime.parse(json['added']),
        purchased: json['purchased'],
        quantity: json['quantity'] ?? 1,
      );
}
