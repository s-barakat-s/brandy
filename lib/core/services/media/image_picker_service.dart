import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

abstract class ProductImagePicker {
  Future<String?> pickImagePath();
}

class ImagePickerService implements ProductImagePicker {
  ImagePickerService(this._picker);

  final ImagePicker _picker;

  @override
  Future<String?> pickImagePath() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }

    final sourceFile = File(image.path);
    if (!sourceFile.existsSync()) {
      return null;
    }

    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final imagesDirectory = Directory(
        '${documentsDirectory.path}${Platform.pathSeparator}images',
      );
      if (!imagesDirectory.existsSync()) {
        imagesDirectory.createSync(recursive: true);
      }

      final extension = _fileExtension(image.name, image.path);
      final fileName = 'picked_${DateTime.now().microsecondsSinceEpoch}$extension';
      final storedFile = File(
        '${imagesDirectory.path}${Platform.pathSeparator}$fileName',
      );

      final copied = await sourceFile.copy(storedFile.path);
      return copied.path;
    } catch (_) {
      return image.path;
    }
  }

  String _fileExtension(String name, String fallbackPath) {
    final source = name.trim().isNotEmpty ? name.trim() : fallbackPath.trim();
    final lastDot = source.lastIndexOf('.');
    if (lastDot == -1 || lastDot == source.length - 1) {
      return '';
    }
    return source.substring(lastDot);
  }
}
