import 'package:uuid/uuid.dart';

abstract class IdGenerator {
  String generate();
}

class UuidGenerator implements IdGenerator {
  const UuidGenerator();

  static const Uuid _uuid = Uuid();

  @override
  String generate() => _uuid.v4();
}

