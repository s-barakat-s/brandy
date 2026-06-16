import 'package:brandy/core/services/database/isar_service.dart';

class AppBootstrap {
  AppBootstrap(this._isarService);

  final IsarService _isarService;

  Future<void> initialize() async {
    await _isarService.initialize();
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }
}

