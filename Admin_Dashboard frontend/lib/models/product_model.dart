class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String? size;
  final String vendorId;
  final String vendorName;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.size,
    required this.vendorId,
    required this.vendorName,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    print('=== PARSING PRODUCT FROM JSON ===');
    print('Raw JSON: $json');

    // Handle different possible ID field names
    String productId = '';
    if (json['_id'] != null) {
      productId = json['_id'].toString();
      print('Using _id: $productId');
    } else if (json['id'] != null) {
      productId = json['id'].toString();
      print('Using id: $productId');
    } else {
      print('⚠️ WARNING: No ID field found in JSON!');
      print('Available keys: ${json.keys.toList()}');
    }

    // Parse images
    List<String> imageList = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        imageList = List<String>.from(json['images']);
      } else if (json['images'] is String) {
        imageList = [json['images']];
      }
    }

    // Parse dates
    DateTime createdAt = DateTime.now();
    DateTime updatedAt = DateTime.now();

    try {
      if (json['createdAt'] != null) {
        createdAt = DateTime.parse(json['createdAt']);
      } else if (json['created_at'] != null) {
        createdAt = DateTime.parse(json['created_at']);
      }
    } catch (e) {
      print('Error parsing createdAt: $e');
    }

    try {
      if (json['updatedAt'] != null) {
        updatedAt = DateTime.parse(json['updatedAt']);
      } else if (json['updated_at'] != null) {
        updatedAt = DateTime.parse(json['updated_at']);
      }
    } catch (e) {
      print('Error parsing updatedAt: $e');
    }

    final product = ProductModel(
      id: productId,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? json['stock_quantity'] ?? 0,
      category: json['category']?.toString() ?? '',
      size: json['size']?.toString(),
      vendorId: json['vendorId']?.toString() ?? json['vendor_id']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? json['vendor_name']?.toString() ?? 'Unknown Vendor',
      images: imageList,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    print('Parsed Product: ${product.name} - ID: "${product.id}" (${product.id.length} chars)');
    return product;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'size': size,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ProductModel(id: "$id", name: "$name", price: $price, stock: $stock, size: "$size")';
  }
}
