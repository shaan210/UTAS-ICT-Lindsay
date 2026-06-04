class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, description: $description, category: $category, price: $price)';
  }
}
