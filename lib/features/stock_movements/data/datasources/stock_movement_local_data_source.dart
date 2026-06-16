import 'package:brandy/core/services/database/isar_service.dart';
import 'package:brandy/features/stock_movements/data/models/stock_movement_record.dart';
import 'package:brandy/features/stock_movements/domain/entities/stock_movement_type.dart';

class StockMovementLocalDataSource {
  StockMovementLocalDataSource(this._isarService);

  final IsarService _isarService;

  final List<StockMovementRecord> _records = [
    StockMovementRecord(
      id: 'movement_hoodie_in',
      brandId: 'brand_acme',
      productId: 'product_hoodie',
      type: StockMovementType.stockIn,
      quantity: 20,
      beforeQuantity: 0,
      afterQuantity: 20,
      unitPrice: 28,
      totalPrice: 560,
      note: 'Opening stock',
      createdAt: DateTime(2026, 3, 1),
    ),
    StockMovementRecord(
      id: 'movement_hoodie_sale',
      brandId: 'brand_acme',
      productId: 'product_hoodie',
      type: StockMovementType.sale,
      quantity: 4,
      beforeQuantity: 20,
      afterQuantity: 16,
      unitPrice: 52,
      totalPrice: 208,
      note: 'Weekend orders',
      createdAt: DateTime(2026, 3, 5),
    ),
  ];

  Future<List<StockMovementRecord>> getMovementsForProduct(String productId) async {
    await _isarService.initialize();
    return _records
        .where((record) => record.productId == productId)
        .toList(growable: false);
  }

  Future<void> saveMovement(StockMovementRecord record) async {
    await _isarService.initialize();
    _records.add(record);
  }
}

