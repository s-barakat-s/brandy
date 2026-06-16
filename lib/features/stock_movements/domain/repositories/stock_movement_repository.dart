import 'package:brandy/features/stock_movements/domain/entities/stock_movement.dart';

abstract class StockMovementRepository {
  Future<List<StockMovement>> getMovementsForProduct(String productId);
  Future<void> saveMovement(StockMovement movement);
}

