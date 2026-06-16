class Product {
  const Product({
    required this.id,
    required this.brandId,
    required this.name,
    required this.code,
    required this.category,
    required this.imagePath,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.supplierName,
    required this.supplierPhone,
    required this.sourceAddress,
    required this.notes,
    required this.currentQuantity,
    required this.lowStockThreshold,
    required this.createdAt,
    required this.updatedAt,
    required this.isArchived,
  });

  final String id;
  final String brandId;
  final String name;
  final String code;
  final String category;
  final String imagePath;
  final double purchasePrice;
  final double sellingPrice;
  final String supplierName;
  final String supplierPhone;
  final String sourceAddress;
  final String notes;
  final int currentQuantity;
  final int lowStockThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  bool get isLowStock => currentQuantity <= lowStockThreshold;

  Product copyWith({
    String? id,
    String? brandId,
    String? name,
    String? code,
    String? category,
    String? imagePath,
    double? purchasePrice,
    double? sellingPrice,
    String? supplierName,
    String? supplierPhone,
    String? sourceAddress,
    String? notes,
    int? currentQuantity,
    int? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return Product(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      supplierName: supplierName ?? this.supplierName,
      supplierPhone: supplierPhone ?? this.supplierPhone,
      sourceAddress: sourceAddress ?? this.sourceAddress,
      notes: notes ?? this.notes,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

