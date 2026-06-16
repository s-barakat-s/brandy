import 'package:brandy/features/products/domain/entities/product.dart';
import 'package:isar_community/isar.dart';

part 'product_record.g.dart';

@collection
class ProductRecord {
  ProductRecord();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String brandId;

  @Index(caseSensitive: false)
  late String name;

  @Index(caseSensitive: false)
  late String code;

  late String category;
  late String imagePath;
  late double purchasePrice;
  late double sellingPrice;
  late String supplierName;
  late String supplierPhone;
  late String sourceAddress;
  late String notes;
  late int currentQuantity;
  late int lowStockThreshold;
  late DateTime createdAt;
  late DateTime updatedAt;

  @Index()
  late bool isArchived;

  Product toEntity() {
    return Product(
      id: id,
      brandId: brandId,
      name: name,
      code: code,
      category: category,
      imagePath: imagePath,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      supplierName: supplierName,
      supplierPhone: supplierPhone,
      sourceAddress: sourceAddress,
      notes: notes,
      currentQuantity: currentQuantity,
      lowStockThreshold: lowStockThreshold,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isArchived: isArchived,
    );
  }

  static ProductRecord fromEntity(Product product) {
    return ProductRecord()
      ..id = product.id
      ..brandId = product.brandId
      ..name = product.name
      ..code = product.code
      ..category = product.category
      ..imagePath = product.imagePath
      ..purchasePrice = product.purchasePrice
      ..sellingPrice = product.sellingPrice
      ..supplierName = product.supplierName
      ..supplierPhone = product.supplierPhone
      ..sourceAddress = product.sourceAddress
      ..notes = product.notes
      ..currentQuantity = product.currentQuantity
      ..lowStockThreshold = product.lowStockThreshold
      ..createdAt = product.createdAt
      ..updatedAt = product.updatedAt
      ..isArchived = product.isArchived;
  }
}
