import 'package:brandy/features/stock_movements/domain/entities/stock_movement_type.dart';

class StockMovement {
  const StockMovement({
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
}

