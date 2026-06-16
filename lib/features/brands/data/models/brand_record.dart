import 'package:brandy/features/brands/domain/entities/brand.dart';
import 'package:isar_community/isar.dart';

part 'brand_record.g.dart';

@collection
class BrandRecord {
  BrandRecord();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index(caseSensitive: false)
  late String name;

  late String type;
  String? logoPath;
  late String description;

  @Index()
  late bool isArchived;

  late DateTime createdAt;
  late DateTime updatedAt;

  Brand toEntity() {
    return Brand(
      id: id,
      name: name,
      type: type,
      logoPath: logoPath,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isArchived: isArchived,
    );
  }

  static BrandRecord fromEntity(Brand brand) {
    return BrandRecord()
      ..id = brand.id
      ..name = brand.name
      ..type = brand.type
      ..logoPath = brand.logoPath
      ..description = brand.description
      ..isArchived = brand.isArchived
      ..createdAt = brand.createdAt
      ..updatedAt = brand.updatedAt;
  }
}
