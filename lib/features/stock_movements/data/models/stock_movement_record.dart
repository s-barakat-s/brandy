import 'package:brandy/features/stock_movements/domain/entities/stock_movement.dart';
import 'package:brandy/features/stock_movements/domain/entities/stock_movement_type.dart';

class StockMovementRecord {
  const StockMovementRecord({
    required this.id,
    required this.brandId,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.beforeQuantity,
    required this.afterQuantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String brandId;
  final String productId;
  final StockMovementType type;
  final int quantity;
  final int beforeQuantity;
  final int afterQuantity;
  final double? unitPrice;
  final double? totalPrice;
  final String note;
  final DateTime createdAt;

  StockMovement toEntity() {
    return StockMovement(
      id: id,
      brandId: brandId,
      productId: productId,
      type: type,
      quantity: quantity,
      beforeQuantity: beforeQuantity,
      afterQuantity: afterQuantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      note: note,
      createdAt: createdAt,
    );
  }

  factory StockMovementRecord.fromEntity(StockMovement movement) {
    return StockMovementRecord(
      id: movement.id,
      brandId: movement.brandId,
      productId: movement.productId,
      type: movement.type,
      quantity: movement.quantity,
      beforeQuantity: movement.beforeQuantity,
      afterQuantity: movement.afterQuantity,
      unitPrice: movement.unitPrice,
      totalPrice: movement.totalPrice,
      note: movement.note,
      createdAt: movement.createdAt,
    );
  }
}

