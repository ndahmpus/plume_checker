import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/portal_stats_models.dart';

class PortalStatsService {
  static const String _baseUrl = 'https://portal-api.plume.org/api/v1';
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const Duration _cacheExpiry = Duration(minutes: 5);

  final http.Client _client;
  final Map<String, _CachedStats> _cache = {};
  bool _isInitialized = false;

  PortalStatsService({http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  Future<void> initialize() async {
    try {
      debugPrint('🔄 PortalStatsService: Initializing...');
      _isInitialized = true;
      debugPrint('✅ PortalStatsService: Initialized successfully');
    } catch (e) {
      debugPrint('❌ PortalStatsService: Initialization failed: $e');
      rethrow;
    }
  }

  bool get isInitialized => _isInitialized;

  Future<PortalStatsResponse?> getWalletStats(
    String walletAddress, {
    bool forceRefresh = false,
  }) async {
    if (!_isInitialized) {
      throw PortalStatsException('PortalStatsService belum diinisialisasi');
    }

    try {
      final normalizedAddress = walletAddress.toLowerCase();

      if (!forceRefresh && _cache.containsKey(normalizedAddress)) {
        final cached = _cache[normalizedAddress]!;
        if (!cached.isExpired) {
          debugPrint('🎯 PortalStatsService: Returning cached data for $walletAddress');
          return cached.data;
        }
      }

      debugPrint('🔄 PortalStatsService: Fetching wallet stats for $walletAddress...');

      final url = '$_baseUrl/stats/wallet?walletAddress=$walletAddress';
      final response = await _client.get(
        Uri.parse(url),
        headers: _getHeaders(),
      ).timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final stats = PortalStatsResponse.fromJson(jsonData);

        _cache[normalizedAddress] = _CachedStats(stats, DateTime.now());

        debugPrint('✅ PortalStatsService: Successfully fetched stats for $walletAddress');
        debugPrint('📊 Stats: ${stats.data.stats.totalXp} XP, ${stats.data.stats.protocolsUsed} protocols');

        return stats;
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ PortalStatsService: Wallet not found: $walletAddress');
        return null;
      } else {
        final errorBody = response.body.isNotEmpty ? response.body : 'No error details';
        debugPrint('❌ PortalStatsService: API error ${response.statusCode}: $errorBody');
        throw PortalStatsException(
          'Gagal mengambil data wallet: ${response.statusCode}',
          statusCode: response.statusCode,
          walletAddress: walletAddress,
        );
      }
    } on SocketException {
      throw PortalStatsException(
        'Tidak ada koneksi internet',
        walletAddress: walletAddress,
      );
    } on TimeoutException {
      throw PortalStatsException(
        'Request timeout - server tidak merespons',
        walletAddress: walletAddress,
      );
    } on FormatException catch (e) {
      throw PortalStatsException(
        'Format data tidak valid: ${e.message}',
        walletAddress: walletAddress,
      );
    } catch (e) {
      if (e is PortalStatsException) rethrow;

      debugPrint('❌ PortalStatsService: Unexpected error: $e');
      throw PortalStatsException(
        'Terjadi kesalahan tidak terduga: $e',
        walletAddress: walletAddress,
      );
    }
  }

  Future<bool> hasWalletActivity(String walletAddress) async {
    try {
      final stats = await getWalletStats(walletAddress);
      return stats != null && stats.data.stats.totalXp > 0;
    } catch (e) {
      debugPrint('Error checking wallet activity: $e');
      return false;
    }
  }

  Future<Map<String, PortalStatsResponse?>> getMultipleWalletStats(
    List<String> walletAddresses, {
    bool forceRefresh = false,
  }) async {
    final results = <String, PortalStatsResponse?>{};

    const batchSize = 3;
    for (int i = 0; i < walletAddresses.length; i += batchSize) {
      final batch = walletAddresses.skip(i).take(batchSize);
      final futures = batch.map((address) => 
        getWalletStats(address, forceRefresh: forceRefresh)
          .then((stats) => MapEntry(address, stats))
          .catchError((error) {
            debugPrint('Error fetching stats for $address: $error');
            return MapEntry(address, null);
          })
      );

      final batchResults = await Future.wait(futures);
      for (final entry in batchResults) {
        results[entry.key] = entry.value;
      }

      if (i + batchSize < walletAddresses.length) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    return results;
  }

  Future<Map<String, dynamic>?> compareWallets(
    String primaryWallet,
    List<String> compareWallets,
  ) async {
    try {
      final allWallets = [primaryWallet, ...compareWallets];
      final stats = await getMultipleWalletStats(allWallets);

      final primaryStats = stats[primaryWallet];
      if (primaryStats == null) return null;

      final comparisons = <String, Map<String, dynamic>>{};

      for (final wallet in compareWallets) {
        final walletStats = stats[wallet];
        if (walletStats != null) {
          comparisons[wallet] = {
            'xp': walletStats.data.stats.totalXp,
            'xpDiff': walletStats.data.stats.totalXp - primaryStats.data.stats.totalXp,
            'protocols': walletStats.data.stats.protocolsUsed,
            'tvl': walletStats.data.stats.tvl,
            'rank': walletStats.data.stats.xpRank,
            'address': walletStats.walletContext.shortAddress,
          };
        }
      }

      return {
        'primary': {
          'address': primaryStats.walletContext.shortAddress,
          'xp': primaryStats.data.stats.totalXp,
          'protocols': primaryStats.data.stats.protocolsUsed,
          'tvl': primaryStats.data.stats.tvl,
          'rank': primaryStats.data.stats.xpRank,
        },
        'comparisons': comparisons,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error comparing wallets: $e');
      return null;
    }
  }

  void clearCache([String? walletAddress]) {
    if (walletAddress != null) {
      _cache.remove(walletAddress.toLowerCase());
      debugPrint('🗑️ PortalStatsService: Cleared cache for $walletAddress');
    } else {
      _cache.clear();
      debugPrint('🗑️ PortalStatsService: All cache cleared');
    }
  }

  Map<String, dynamic> getCacheInfo() {
    final now = DateTime.now();
    return {
      'totalCached': _cache.length,
      'cacheKeys': _cache.keys.toList(),
      'expiredCount': _cache.values.where((c) => c.isExpired).length,
      'validCount': _cache.values.where((c) => !c.isExpired).length,
      'oldestEntry': _cache.values.isEmpty 
          ? null 
          : _cache.values
              .map((c) => now.difference(c.timestamp).inMinutes)
              .reduce((a, b) => a > b ? a : b),
      'newestEntry': _cache.values.isEmpty 
          ? null 
          : _cache.values
              .map((c) => now.difference(c.timestamp).inMinutes)
              .reduce((a, b) => a < b ? a : b),
    };
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'PlumeVelocity/1.0.0',
      'X-Requested-With': 'XMLHttpRequest',
    };
  }

  void cleanupCache() {
    _cache.removeWhere((key, value) => value.isExpired);
    debugPrint('🧹 PortalStatsService: Cleaned up expired cache entries');
  }

  void dispose() {
    _cache.clear();
    _client.close();
    _isInitialized = false;
    debugPrint('🔄 PortalStatsService: Disposed');
  }
}

class _CachedStats {
  final PortalStatsResponse data;
  final DateTime timestamp;

  _CachedStats(this.data, this.timestamp);

  bool get isExpired => 
      DateTime.now().difference(timestamp) > PortalStatsService._cacheExpiry;
}
