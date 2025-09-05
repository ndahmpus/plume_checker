import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../base/base_service.dart';
import '../../models/plume_portal_models.dart';

class PlumePortalService extends BaseService {
  static const String _baseUrl = 'https://portal-api.plume.org/api/v1';
  static const Duration _defaultTimeout = Duration(seconds: 10);
  static const Duration _cacheTimeout = Duration(minutes: 5);

  late http.Client _httpClient;
  final Map<String, _CachedResponse> _cache = {};

  PlumePortalService() : super('PlumePortalService');

  @override
  Future<void> onInitialize() async {
    _httpClient = http.Client();
    logInfo('HTTP client initialized');
  }

  @override
  Future<void> onDispose() async {
    _httpClient.close();
    _cache.clear();
    logInfo('HTTP client disposed and cache cleared');
  }

  Future<PlumePortalResponse?> getPpTotals(
    String walletAddress, {
    bool forceRefresh = false,
  }) async {
    requireInitialized();

    if (!_isValidEthereumAddress(walletAddress)) {
      logError('Invalid Ethereum address format: $walletAddress');
      throw ArgumentError('Invalid Ethereum address format');
    }

    final cacheKey = 'pp-totals-$walletAddress';

    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      final cachedResponse = _cache[cacheKey]!;
      if (!cachedResponse.isExpired) {
        logDebug('Returning cached data for $walletAddress');
        return cachedResponse.data;
      } else {
        logDebug('Cache expired for $walletAddress, fetching fresh data');
        _cache.remove(cacheKey);
      }
    }

    return await safeExecute<PlumePortalResponse>(
      () async {
        final url = '$_baseUrl/stats/pp-totals?walletAddress=$walletAddress';
        logDebug('Making API request to: $url');

        final response = await _httpClient
            .get(
              Uri.parse(url),
              headers: _getDefaultHeaders(),
            )
            .timeout(_defaultTimeout);

        logDebug('API response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body) as Map<String, dynamic>;
          final plumeResponse = PlumePortalResponse.fromJson(jsonData);

          _cache[cacheKey] = _CachedResponse(
            data: plumeResponse,
            cachedAt: DateTime.now(),
          );

          logSuccess('Successfully fetched PP totals for $walletAddress');
          return plumeResponse;

        } else if (response.statusCode == 404) {
          logWarning('Wallet address not found: $walletAddress');
          throw PlumePortalException(
            'Wallet address not found',
            statusCode: 404,
          );

        } else if (response.statusCode == 429) {
          logWarning('Rate limit exceeded');
          throw PlumePortalException(
            'Rate limit exceeded. Please try again later.',
            statusCode: 429,
          );

        } else {
          logError('API request failed with status: ${response.statusCode}');
          throw PlumePortalException(
            'Failed to fetch data: ${response.reasonPhrase}',
            statusCode: response.statusCode,
          );
        }
      },
      operationName: 'getPpTotals for $walletAddress',
    );
  }

  Future<Map<String, PlumePortalResponse?>> getMultiplePpTotals(
    List<String> walletAddresses, {
    bool forceRefresh = false,
  }) async {
    requireInitialized();

    final results = <String, PlumePortalResponse?>{};

    final futures = walletAddresses.map((address) async {
      try {
        final data = await getPpTotals(address, forceRefresh: forceRefresh);
        results[address] = data;
      } catch (e) {
        logWarning('Failed to fetch data for $address: $e');
        results[address] = null;
      }
    });

    await Future.wait(futures);

    logInfo('Fetched data for ${results.length} wallet addresses');
    return results;
  }

  void clearCache([String? walletAddress]) {
    if (walletAddress != null) {
      final cacheKey = 'pp-totals-$walletAddress';
      _cache.remove(cacheKey);
      logDebug('Cache cleared for $walletAddress');
    } else {
      _cache.clear();
      logDebug('All cache cleared');
    }
  }

  Map<String, dynamic> getCacheInfo() {
    return {
      'totalCachedItems': _cache.length,
      'cachedAddresses': _cache.keys.map((key) => key.replaceFirst('pp-totals-', '')).toList(),
      'cacheExpiry': _cacheTimeout.inMinutes,
    };
  }

  Map<String, String> _getDefaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'PlumeVelocityApp/1.0',
      if (!kIsWeb) 'Connection': 'keep-alive',
    };
  }

  bool _isValidEthereumAddress(String address) {
    return RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address);
  }
}

class _CachedResponse {
  final PlumePortalResponse data;
  final DateTime cachedAt;

  _CachedResponse({
    required this.data,
    required this.cachedAt,
  });

  bool get isExpired {
    return DateTime.now().difference(cachedAt) > PlumePortalService._cacheTimeout;
  }
}

class PlumePortalException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  PlumePortalException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('PlumePortalException: $message');
    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }
    if (originalError != null) {
      buffer.write(' - Original: $originalError');
    }
    return buffer.toString();
  }
}

extension PlumePortalServiceUtils on PlumePortalService {
  Future<bool> hasActivity(String walletAddress) async {
    try {
      final response = await getPpTotals(walletAddress);
      return (response?.data.ppScores.activeXp.totalXp ?? 0) > 0;
    } catch (e) {
      debugPrint('Failed to check activity for $walletAddress: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getXpComparison(
    String walletAddress,
    List<String> compareAddresses,
  ) async {
    final allAddresses = [walletAddress, ...compareAddresses];
    final results = await getMultiplePpTotals(allAddresses);

    final xpData = <String, int>{};
    for (final entry in results.entries) {
      if (entry.value != null) {
        xpData[entry.key] = entry.value!.data.ppScores.activeXp.totalXp;
      }
    }

    final sortedEntries = xpData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final userRank = sortedEntries.indexWhere(
      (entry) => entry.key.toLowerCase() == walletAddress.toLowerCase(),
    ) + 1;

    return {
      'userAddress': walletAddress,
      'userXp': xpData[walletAddress] ?? 0,
      'userRank': userRank,
      'totalCompared': sortedEntries.length,
      'rankings': sortedEntries.map((e) => {
        'address': e.key,
        'xp': e.value,
      }).toList(),
    };
  }
}
