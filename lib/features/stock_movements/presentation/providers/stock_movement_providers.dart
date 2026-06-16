import 'package:brandy/core/services/core_providers.dart';
import 'package:brandy/core/services/id/id_generator.dart';
import 'package:brandy/features/products/domain/entities/product.dart';
import 'package:brandy/features/products/domain/repositories/product_repository.dart';
import 'package:brandy/features/products/presentation/providers/product_providers.dart';
import 'package:brandy/features/stock_movements/data/datasources/stock_movement_local_data_source.dart';
import 'package:brandy/features/stock_movements/data/repositories/local_stock_movement_repository.dart';
import 'package:brandy/features/stock_movements/domain/entities/stock_movement.dart';
import 'package:brandy/features/stock_movements/domain/entities/stock_movement_type.dart';
import 'package:brandy/features/stock_movements/domain/repositories/stock_movement_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovementInput {
  const MovementInput({
    required this.brandId,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.note,
  });

  final String brandId;
  final String productId;
  final StockMovementType type;
  final int quantity;
  final double? unitPrice;
  final String note;
}

class StockMovementEditor {
  StockMovementEditor({
    required StockMovementRepository movementRepository,
    required ProductRepository productRepository,
    required IdGenerator idGenerator,
  })  : _movementRepository = movementRepository,
        _productRepository = productRepository,
        _idGenerator = idGenerator;

  final StockMovementRepository _movementRepository;
  final ProductRepository _productRepository;
  final IdGenerator _idGenerator;

  Future<void> addMovement({
    required Product product,
    required MovementInput input,
  }) async {
    final delta = switch (input.type) {
      StockMovementType.stockIn => input.quantity,
      StockMovementType.sale => -input.quantity,
      StockMovementType.adjustment => input.quantity,
    };
    final afterQuantity = input.type == StockMovementType.adjustment
        ? input.quantity
        : product.currentQuantity + delta;

    final updatedProduct = product.copyWith(
      currentQuantity: afterQuantity,
      updatedAt: DateTime.now(),
    );

    final movement = StockMovement(
      id: _idGenerator.generate(),
      brandId: input.brandId,
      productId: input.productId,
      type: input.type,
      quantity: input.quantity,
      beforeQuantity: product.currentQuantity,
      afterQuantity: afterQuantity,
      unitPrice: input.unitPrice,
      totalPrice: input.unitPrice == null ? null : input.unitPrice! * input.quantity,
      note: input.note,
      createdAt: DateTime.now(),
    );

    await _productRepository.updateProduct(updatedProduct);
    await _movementRepository.saveMovement(movement);
  }
}

final stockMovementLocalDataSourceProvider =
    Provider<StockMovementLocalDataSource>((ref) {
  return StockMovementLocalDataSource(ref.watch(isarServiceProvider));
});

final stockMovementRepositoryProvider = Provider<StockMovementRepository>((ref) {
  return LocalStockMovementRepository(
    ref.watch(stockMovementLocalDataSourceProvider),
  );
});

final stockMovementsByProductProvider =
    FutureProvider.family<List<StockMovement>, String>((ref, productId) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(stockMovementRepositoryProvider).getMovementsForProduct(productId);
});

final stockMovementEditorProvider = Provider<StockMovementEditor>((ref) {
  return StockMovementEditor(
    movementRepository: ref.watch(stockMovementRepositoryProvider),
    productRepository: ref.watch(productRepositoryProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  );
});
