import 'package:brandy/features/stock_movements/data/datasources/stock_movement_local_data_source.dart';
import 'package:brandy/features/stock_movements/data/models/stock_movement_record.dart';
import 'package:brandy/features/stock_movements/domain/entities/stock_movement.dart';
import 'package:brandy/features/stock_movements/domain/repositories/stock_movement_repository.dart';

class LocalStockMovementRepository implements StockMovementRepository {
  LocalStockMovementRepository(this._localDataSource);

  final StockMovementLocalDataSource _localDataSource;

  @override
  Future<List<StockMovement>> getMovementsForProduct(String productId) async {
    final records = await _localDataSource.getMovementsForProduct(productId);
    return records.map((record) => record.toEntity()).toList();
  }

  @override
  Future<void> saveMovement(StockMovement movement) {
    return _localDataSource.saveMovement(StockMovementRecord.fromEntity(movement));
  }
}

