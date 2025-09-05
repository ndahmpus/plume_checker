import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class CacheService {
  static CacheService? _instance;
  SharedPreferences? _prefs;

  CacheService._();

  static CacheService get instance {
    _instance ??= CacheService._();
    return _instance!;
  }

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool _isCacheValid(String timestampKey) {
    final timestampStr = _prefs?.getString(timestampKey);
    if (timestampStr == null) return false;

    try {
      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference.inMinutes < StorageKeys.cacheValidDurationMinutes;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveToCache(String dataKey, String timestampKey, String jsonData) async {
    await initialize();
    await _prefs?.setString(dataKey, jsonData);
    await _prefs?.setString(timestampKey, DateTime.now().toIso8601String());
  }

  String? _getFromCache(String dataKey, String timestampKey) {
    if (!_isCacheValid(timestampKey)) return null;
    return _prefs?.getString(dataKey);
  }

  Future<void> _clearCache(String dataKey, String timestampKey) async {
    await initialize();
    await _prefs?.remove(dataKey);
    await _prefs?.remove(timestampKey);
  }

  Future<void> saveWalletData(String walletAddress, String jsonData) async {
    await _saveToCache(
      '${StorageKeys.cachedWalletData}$walletAddress',
      '${StorageKeys.cachedWalletDataTimestamp}$walletAddress',
      jsonData,
    );
  }

  String? getWalletData(String walletAddress) {
    return _getFromCache(
      '${StorageKeys.cachedWalletData}$walletAddress',
      '${StorageKeys.cachedWalletDataTimestamp}$walletAddress',
    );
  }

  bool isWalletDataCacheValid(String walletAddress) {
    return _isCacheValid('${StorageKeys.cachedWalletDataTimestamp}$walletAddress');
  }

  Future<void> clearWalletDataCache(String walletAddress) async {
    await _clearCache(
      '${StorageKeys.cachedWalletData}$walletAddress',
      '${StorageKeys.cachedWalletDataTimestamp}$walletAddress',
    );
  }

  Future<void> savePpScores(String walletAddress, String jsonData) async {
    await _saveToCache(
      '${StorageKeys.cachedPpScores}$walletAddress',
      '${StorageKeys.cachedPpScoresTimestamp}$walletAddress',
      jsonData,
    );
  }

  String? getPpScores(String walletAddress) {
    return _getFromCache(
      '${StorageKeys.cachedPpScores}$walletAddress',
      '${StorageKeys.cachedPpScoresTimestamp}$walletAddress',
    );
  }

  bool isPpScoresCacheValid(String walletAddress) {
    return _isCacheValid('${StorageKeys.cachedPpScoresTimestamp}$walletAddress');
  }

  Future<void> clearPpScoresCache(String walletAddress) async {
    await _clearCache(
      '${StorageKeys.cachedPpScores}$walletAddress',
      '${StorageKeys.cachedPpScoresTimestamp}$walletAddress',
    );
  }

  Future<void> savePortalStats(String walletAddress, String jsonData) async {
    await _saveToCache(
      '${StorageKeys.cachedPortalStats}$walletAddress',
      '${StorageKeys.cachedPortalStatsTimestamp}$walletAddress',
      jsonData,
    );
  }

  String? getPortalStats(String walletAddress) {
    return _getFromCache(
      '${StorageKeys.cachedPortalStats}$walletAddress',
      '${StorageKeys.cachedPortalStatsTimestamp}$walletAddress',
    );
  }

  bool isPortalStatsCacheValid(String walletAddress) {
    return _isCacheValid('${StorageKeys.cachedPortalStatsTimestamp}$walletAddress');
  }

  Future<void> clearPortalStatsCache(String walletAddress) async {
    await _clearCache(
      '${StorageKeys.cachedPortalStats}$walletAddress',
      '${StorageKeys.cachedPortalStatsTimestamp}$walletAddress',
    );
  }

  Future<void> saveSkySociety(String walletAddress, String jsonData) async {
    await _saveToCache(
      '${StorageKeys.cachedSkySociety}$walletAddress',
      '${StorageKeys.cachedSkySocietyTimestamp}$walletAddress',
      jsonData,
    );
  }

  String? getSkySociety(String walletAddress) {
    return _getFromCache(
      '${StorageKeys.cachedSkySociety}$walletAddress',
      '${StorageKeys.cachedSkySocietyTimestamp}$walletAddress',
    );
  }

  bool isSkySocietyCacheValid(String walletAddress) {
    return _isCacheValid('${StorageKeys.cachedSkySocietyTimestamp}$walletAddress');
  }

  Future<void> clearSkySocietyCache(String walletAddress) async {
    await _clearCache(
      '${StorageKeys.cachedSkySociety}$walletAddress',
      '${StorageKeys.cachedSkySocietyTimestamp}$walletAddress',
    );
  }

  Future<void> saveWalletBalance(String walletAddress, String jsonData) async {
    await _saveToCache(
      '${StorageKeys.cachedWalletBalance}$walletAddress',
      '${StorageKeys.cachedWalletBalanceTimestamp}$walletAddress',
      jsonData,
    );
  }

  String? getWalletBalance(String walletAddress) {
    return _getFromCache(
      '${StorageKeys.cachedWalletBalance}$walletAddress',
      '${StorageKeys.cachedWalletBalanceTimestamp}$walletAddress',
    );
  }

  bool isWalletBalanceCacheValid(String walletAddress) {
    return _isCacheValid('${StorageKeys.cachedWalletBalanceTimestamp}$walletAddress');
  }

  Future<void> clearWalletBalanceCache(String walletAddress) async {
    await _clearCache(
      '${StorageKeys.cachedWalletBalance}$walletAddress',
      '${StorageKeys.cachedWalletBalanceTimestamp}$walletAddress',
    );
  }

  Future<void> saveDailySpin(String walletAddress, String jsonData) async {
    await _saveToCache(
      '${StorageKeys.cachedDailySpin}$walletAddress',
      '${StorageKeys.cachedDailySpinTimestamp}$walletAddress',
      jsonData,
    );
  }

  String? getDailySpin(String walletAddress) {
    return _getFromCache(
      '${StorageKeys.cachedDailySpin}$walletAddress',
      '${StorageKeys.cachedDailySpinTimestamp}$walletAddress',
    );
  }

  bool isDailySpinCacheValid(String walletAddress) {
    return _isCacheValid('${StorageKeys.cachedDailySpinTimestamp}$walletAddress');
  }

  Future<void> clearDailySpinCache(String walletAddress) async {
    await _clearCache(
      '${StorageKeys.cachedDailySpin}$walletAddress',
      '${StorageKeys.cachedDailySpinTimestamp}$walletAddress',
    );
  }

  Future<void> clearAllCacheForWallet(String walletAddress) async {
    await Future.wait([
      clearWalletDataCache(walletAddress),
      clearPpScoresCache(walletAddress),
      clearPortalStatsCache(walletAddress),
      clearSkySocietyCache(walletAddress),
      clearWalletBalanceCache(walletAddress),
      clearDailySpinCache(walletAddress),
    ]);
  }

  Future<void> clearAllCache() async {
    await initialize();
    final keys = _prefs?.getKeys() ?? <String>{};

    final cacheKeys = keys.where((key) => 
      key.startsWith(StorageKeys.cachedWalletData) ||
      key.startsWith(StorageKeys.cachedWalletDataTimestamp) ||
      key.startsWith(StorageKeys.cachedPpScores) ||
      key.startsWith(StorageKeys.cachedPpScoresTimestamp) ||
      key.startsWith(StorageKeys.cachedPortalStats) ||
      key.startsWith(StorageKeys.cachedPortalStatsTimestamp) ||
      key.startsWith(StorageKeys.cachedSkySociety) ||
      key.startsWith(StorageKeys.cachedSkySocietyTimestamp) ||
      key.startsWith(StorageKeys.cachedWalletBalance) ||
      key.startsWith(StorageKeys.cachedWalletBalanceTimestamp) ||
      key.startsWith(StorageKeys.cachedDailySpin) ||
      key.startsWith(StorageKeys.cachedDailySpinTimestamp)
    );

    for (final key in cacheKeys) {
      await _prefs?.remove(key);
    }
  }

  Map<String, bool> getCacheStatus(String walletAddress) {
    return {
      'walletData': isWalletDataCacheValid(walletAddress),
      'ppScores': isPpScoresCacheValid(walletAddress),
      'portalStats': isPortalStatsCacheValid(walletAddress),
      'skySociety': isSkySocietyCacheValid(walletAddress),
      'walletBalance': isWalletBalanceCacheValid(walletAddress),
      'dailySpin': isDailySpinCacheValid(walletAddress),
    };
  }
}
