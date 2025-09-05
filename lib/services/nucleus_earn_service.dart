import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/base/base_service.dart';
import '../models/nucleus_earn_models.dart';

class NucleusEarnService extends BaseService {
  static const String _baseUrl = 'https://backend.nucleusearn.io/v1/plume';
  static const Duration _defaultTimeout = Duration(seconds: 15);
  static const Duration _cacheTimeout = Duration(minutes: 3);

  late http.Client _httpClient;
  final Map<String, _CachedPortfolioResponse> _cache = {};

  NucleusEarnService() : super('NucleusEarnService');

  @override
  Future<void> onInitialize() async {
    _httpClient = http.Client();
    logInfo('Nucleus Earn HTTP client initialized');
  }

  @override
  Future<void> onDispose() async {
    _httpClient.close();
    _cache.clear();
    logInfo('Nucleus Earn HTTP client disposed and cache cleared');
  }

  Future<UserPortfolioResponse?> getUserPortfolio(
    String walletAddress, {
    bool forceRefresh = false,
  }) async {
    requireInitialized();

    if (!_isValidEthereumAddress(walletAddress)) {
      logError('Invalid Ethereum address format: $walletAddress');
      throw ArgumentError('Invalid Ethereum address format');
    }

    final cacheKey = 'portfolio-${walletAddress.toLowerCase()}';

    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      final cachedResponse = _cache[cacheKey]!;
      if (!cachedResponse.isExpired) {
        logDebug('Returning cached portfolio data for $walletAddress');
        return cachedResponse.data;
      } else {
        logDebug('Cache expired for $walletAddress, fetching fresh data');
        _cache.remove(cacheKey);
      }
    }

    return await safeExecute<UserPortfolioResponse>(
      () async {
        final url = '$_baseUrl/user-portfolio?user_address=${walletAddress.toLowerCase()}';
        logDebug('Making API request to: $url');

        final response = await _httpClient
            .get(
              Uri.parse(url),
              headers: _getDefaultHeaders(),
            )
            .timeout(_defaultTimeout);

        logDebug('Portfolio API response status: ${response.statusCode}');
        logDebug('Portfolio API response body: ${response.body}');

        if (response.statusCode == 200) {
          final dynamic jsonData = json.decode(response.body);

          if (jsonData is List && jsonData.isEmpty) {
            logInfo('Empty portfolio data for $walletAddress');
            final emptyResponse = UserPortfolioResponse.empty(walletAddress);

            _cache[cacheKey] = _CachedPortfolioResponse(
              data: emptyResponse,
              cachedAt: DateTime.now(),
            );

            return emptyResponse;
          }

          UserPortfolioResponse portfolioResponse;
          if (jsonData is List && jsonData.isNotEmpty) {
            portfolioResponse = UserPortfolioResponse.fromJsonList(jsonData, walletAddress);
          } else if (jsonData is Map<String, dynamic>) {
            portfolioResponse = UserPortfolioResponse.fromJson(jsonData, walletAddress);
          } else {
            throw FormatException('Unexpected response format');
          }

          _cache[cacheKey] = _CachedPortfolioResponse(
            data: portfolioResponse,
            cachedAt: DateTime.now(),
          );

          if (portfolioResponse.hasData) {
            final topAssets = portfolioResponse.topAssets;
            debugPrint('📊 Top Assets Summary for $walletAddress:');
            debugPrint('   Total Portfolio Value: \$${portfolioResponse.totalValue.toStringAsFixed(2)}');
            debugPrint('   Total Tokens: ${portfolioResponse.totalTokenCount}');
            for (int i = 0; i < topAssets.length; i++) {
              final asset = topAssets[i];
              debugPrint('   ${i + 1}. ${asset.tokenSymbol} (${asset.tokenName}) - \$${asset.totalValue.toStringAsFixed(2)}');
            }
          }

          logSuccess('Successfully fetched portfolio for $walletAddress');
          return portfolioResponse;

        } else if (response.statusCode == 404) {
          logWarning('Portfolio not found for wallet: $walletAddress');
          final emptyResponse = UserPortfolioResponse.empty(walletAddress);
          _cache[cacheKey] = _CachedPortfolioResponse(
            data: emptyResponse,
            cachedAt: DateTime.now(),
          );
          return emptyResponse;

        } else if (response.statusCode == 429) {
          logWarning('Rate limit exceeded for Nucleus Earn API');
          throw NucleusEarnException(
            'Terlalu banyak request. Mohon tunggu beberapa saat.',
            statusCode: 429,
          );

        } else {
          logError('Portfolio API request failed with status: ${response.statusCode}');
          throw NucleusEarnException(
            'Failed to fetch portfolio data: ${response.reasonPhrase}',
            statusCode: response.statusCode,
          );
        }
      },
      operationName: 'getUserPortfolio for $walletAddress',
    );
  }

  Future<Map<String, UserPortfolioResponse?>> getMultiplePortfolios(
    List<String> walletAddresses, {
    bool forceRefresh = false,
  }) async {
    requireInitialized();

    final results = <String, UserPortfolioResponse?>{};

    final futures = walletAddresses.map((address) async {
      try {
        final data = await getUserPortfolio(address, forceRefresh: forceRefresh);
        results[address] = data;
      } catch (e) {
        logWarning('Failed to fetch portfolio for $address: $e');
        results[address] = null;
      }
    });

    await Future.wait(futures);

    logInfo('Fetched portfolios for ${results.length} wallet addresses');
    return results;
  }

  Future<bool> hasPortfolioData(String walletAddress) async {
    try {
      final portfolio = await getUserPortfolio(walletAddress);
      return portfolio != null && portfolio.hasData;
    } catch (e) {
      logWarning('Failed to check portfolio data for $walletAddress: $e');
      return false;
    }
  }

  void clearCache([String? walletAddress]) {
    if (walletAddress != null) {
      final cacheKey = 'portfolio-${walletAddress.toLowerCase()}';
      _cache.remove(cacheKey);
      logDebug('Portfolio cache cleared for $walletAddress');
    } else {
      _cache.clear();
      logDebug('All portfolio cache cleared');
    }
  }

  Map<String, dynamic> getCacheInfo() {
    return {
      'totalCachedPortfolios': _cache.length,
      'cachedAddresses': _cache.keys
          .map((key) => key.replaceFirst('portfolio-', ''))
          .toList(),
      'cacheExpiry': _cacheTimeout.inMinutes,
    };
  }

  Future<Map<String, dynamic>> getPortfolioStats(String walletAddress) async {
    try {
      final portfolio = await getUserPortfolio(walletAddress);
      if (portfolio == null || !portfolio.hasData) {
        return {
          'totalValue': 0.0,
          'totalTokens': 0,
          'hasData': false,
        };
      }

      return {
        'totalValue': portfolio.totalValue,
        'totalTokens': portfolio.portfolioItems.length,
        'hasData': portfolio.hasData,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      logError('Failed to get portfolio stats for $walletAddress: $e');
      return {
        'totalValue': 0.0,
        'totalTokens': 0,
        'hasData': false,
        'error': e.toString(),
      };
    }
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

class _CachedPortfolioResponse {
  final UserPortfolioResponse data;
  final DateTime cachedAt;

  _CachedPortfolioResponse({
    required this.data,
    required this.cachedAt,
  });

  bool get isExpired {
    return DateTime.now().difference(cachedAt) > NucleusEarnService._cacheTimeout;
  }
}

class NucleusEarnException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  NucleusEarnException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('NucleusEarnException: $message');
    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }
    if (originalError != null) {
      buffer.write(' - Original: $originalError');
    }
    return buffer.toString();
  }
}

extension NucleusEarnServiceUtils on NucleusEarnService {
  Future<double> getPortfolioValue(String walletAddress) async {
    try {
      final portfolio = await getUserPortfolio(walletAddress);
      return portfolio?.totalValue ?? 0.0;
    } catch (e) {
      debugPrint('Failed to get portfolio value for $walletAddress: $e');
      return 0.0;
    }
  }

  Future<String> getPortfolioSummary(String walletAddress) async {
    try {
      final portfolio = await getUserPortfolio(walletAddress);
      if (portfolio == null || !portfolio.hasData) {
        return 'No portfolio data available';
      }

      return '${portfolio.portfolioItems.length} tokens with total value \$${portfolio.totalValue.toStringAsFixed(2)}';
    } catch (e) {
      return 'Error loading portfolio';
    }
  }
}
