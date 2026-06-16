class Brand {
  const Brand({
    required this.id,
    required this.name,
    required this.type,
    required this.logoPath,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.isArchived,
  });

  final String id;
  final String name;
  final String type;
  final String? logoPath;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  Brand copyWith({
    String? id,
    String? name,
    String? type,
    String? logoPath,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return Brand(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      logoPath: logoPath ?? this.logoPath,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
