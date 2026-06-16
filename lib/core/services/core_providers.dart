import 'package:brandy/core/services/app_bootstrap.dart';
import 'package:brandy/core/services/database/isar_service.dart';
import 'package:brandy/core/services/id/id_generator.dart';
import 'package:brandy/core/services/media/image_picker_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final idGeneratorProvider = Provider<IdGenerator>((ref) {
  return const UuidGenerator();
});

final imagePickerProvider = Provider<ProductImagePicker>((ref) {
  return ImagePickerService(ImagePicker());
});

final appBootstrapProvider = FutureProvider<void>((ref) async {
  final bootstrap = AppBootstrap(ref.watch(isarServiceProvider));
  await bootstrap.initialize();
});

