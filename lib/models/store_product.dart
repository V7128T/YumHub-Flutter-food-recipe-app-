class Product {
  final int id;
  final String name;
  final double price;
  final String unit;
  final double packageSize;
  final String packageUnit;
  int stock;
  final List<String> aliases;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.packageSize,
    required this.packageUnit,
    required this.stock,
    this.aliases = const [],
  });

  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? unit,
    double? packageSize,
    String? packageUnit,
    int? stock,
    List<String>? aliases,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      packageSize: packageSize ?? this.packageSize,
      packageUnit: packageUnit ?? this.packageUnit,
      stock: stock ?? this.stock,
      aliases: aliases ?? this.aliases,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String,
      packageSize: (json['packageSize'] as num).toDouble(),
      packageUnit: json['packageUnit'] as String,
      stock: json['stock'] as int? ?? 0,
      aliases: List<String>.from(json['aliases'] ?? []),
    );
  }
}
