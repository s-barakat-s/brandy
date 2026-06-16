import 'package:brandy/features/brands/data/models/brand_record.dart';
import 'package:brandy/features/products/data/models/product_record.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static const _instanceName = 'brandy_inventory';

  Isar? _instance;

  Future<void> initialize() async {
    await instance;
  }

  Future<Isar> get instance async {
    final cached = _instance;
    if (cached != null && cached.isOpen) {
      return cached;
    }

    final existing = Isar.getInstance(_instanceName);
    if (existing != null && existing.isOpen) {
      _instance = existing;
      return existing;
    }

    final directory = await getApplicationDocumentsDirectory();
    final opened = await Isar.open(
      [BrandRecordSchema, ProductRecordSchema],
      directory: directory.path,
      name: _instanceName,
    );
    _instance = opened;
    return opened;
  }

  Future<void> close() async {
    final isar = _instance;
    if (isar != null && isar.isOpen) {
      await isar.close();
    }
    _instance = null;
  }
}
