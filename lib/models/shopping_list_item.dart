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

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      recipeId: json['recipeId'] as String?,
      recipeName: json['recipeName'] as String?,
      added: json['added'] != null
          ? DateTime.parse(json['added'] as String)
          : DateTime.now(),
      purchased: json['purchased'] as bool? ?? false,
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}
