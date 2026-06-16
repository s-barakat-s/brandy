import 'package:flutter/widgets.dart';

ImageProvider<Object>? resolveImageProvider(String? path) {
  final normalized = path?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  if (normalized.startsWith('assets/')) {
    return AssetImage(normalized);
  }

  final uri = Uri.tryParse(normalized);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return NetworkImage(normalized);
  }

  return null;
}
