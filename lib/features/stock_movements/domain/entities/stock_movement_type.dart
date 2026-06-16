enum StockMovementType {
  stockIn,
  sale,
  adjustment,
}

extension StockMovementTypeX on StockMovementType {
  String toDisplayLabel() {
    return switch (this) {
      StockMovementType.stockIn => 'Stock In',
      StockMovementType.sale => 'Sale',
      StockMovementType.adjustment => 'Adjustment',
    };
  }
}
