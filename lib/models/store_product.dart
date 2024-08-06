class Product {
  final int id;
  final String name;
  final double price;
  final String unit;
  final double packageSize;
  final String packageUnit;
  final List<String> aliases;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.packageSize,
    required this.packageUnit,
    this.aliases = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String,
      packageSize: (json['packageSize'] as num).toDouble(),
      packageUnit: json['packageUnit'] as String,
      aliases: List<String>.from(json['aliases'] ?? []),
    );
  }
}
