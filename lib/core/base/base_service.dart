import 'dart:async';

abstract class BaseService {
  bool _isInitialized = false;
  String _serviceName = '';

  BaseService(this._serviceName);

  String get serviceName => _serviceName;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    logInfo('Initializing $_serviceName...');
    try {
      await onInitialize();
      _isInitialized = true;
      logInfo('$_serviceName initialized successfully');
    } catch (e) {
      logError('Failed to initialize $_serviceName: $e');
      rethrow;
    }
  }

  Future<void> onInitialize();

  void requireInitialized() {
    if (!_isInitialized) {
      throw StateError('Service $_serviceName is not initialized');
    }
  }

  Future<void> dispose() async {
    logInfo('Disposing $_serviceName...');
    await onDispose();
    _isInitialized = false;
    logInfo('$_serviceName disposed');
  }

  Future<void> onDispose() async {}

  Future<T> safeExecute<T>(
    Future<T> Function() operation, {
    T Function()? fallback,
    String? operationName,
  }) async {
    try {
      logDebug('Executing ${operationName ?? 'operation'} in $_serviceName');
      return await operation();
    } catch (e) {
      logError('Error in ${operationName ?? 'operation'}: $e');
      if (fallback != null) {
        logWarning('Using fallback for ${operationName ?? 'operation'}');
        return fallback();
      }
      rethrow;
    }
  }

  void logInfo(String message) {
    print('ℹ️ [$_serviceName] $message');
  }

  void logDebug(String message) {
    print('🔍 [$_serviceName] $message');
  }

  void logWarning(String message) {
    print('⚠️ [$_serviceName] $message');
  }

  void logError(String message) {
    print('❌ [$_serviceName] $message');
  }

  void logSuccess(String message) {
    print('✅ [$_serviceName] $message');
  }
}
