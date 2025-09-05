import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';

import '../models/plume_portal_models.dart';
import '../models/season1_allocation_models.dart';
import 'cache_service.dart';

class PlumeStatsData {
  final double? totalPredictionPoints;
  final double? totalRewards;
  final int? totalPredictions;
  final double? averageAccuracy;
  final String? rank;
  final DateTime lastUpdated;
  final bool isError;
  final String? errorMessage;

  const PlumeStatsData({
    this.totalPredictionPoints,
    this.totalRewards,
    this.totalPredictions,
    this.averageAccuracy,
    this.rank,
    required this.lastUpdated,
    this.isError = false,
    this.errorMessage,
  });

  factory PlumeStatsData.error(String message) {
    return PlumeStatsData(
      lastUpdated: DateTime.now(),
      isError: true,
      errorMessage: message,
    );
  }

  factory PlumeStatsData.fromJson(Map<String, dynamic> json) {
    try {
      return PlumeStatsData(
        totalPredictionPoints: _parseDouble(json['totalPredictionPoints']),
        totalRewards: _parseDouble(json['totalRewards']),
        totalPredictions: _parseInt(json['totalPredictions']),
        averageAccuracy: _parseDouble(json['averageAccuracy']),
        rank: json['rank']?.toString(),
        lastUpdated: DateTime.now(),
        isError: false,
      );
    } catch (e) {
      debugPrint('Error parsing PlumeStatsData: $e');
      return PlumeStatsData.error('Failed to parse data: $e');
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  String toString() {
    if (isError) return 'PlumeStatsData.error($errorMessage)';
    return 'PlumeStatsData(pp: $totalPredictionPoints, predictions: $totalPredictions, accuracy: $averageAccuracy%)';
  }
}

class PlumeWalletData {
  final String? walletAddress;
  final double? balance;
  final List<PredictionData>? predictions;
  final Map<String, dynamic>? portfolioStats;
  final Map<String, dynamic>? activityHistory;
  final Map<String, dynamic>? rewards;
  final Map<String, dynamic>? rankings;
  final DateTime lastUpdated;
  final bool isError;
  final String? errorMessage;

  const PlumeWalletData({
    this.walletAddress,
    this.balance,
    this.predictions,
    this.portfolioStats,
    this.activityHistory,
    this.rewards,
    this.rankings,
    required this.lastUpdated,
    this.isError = false,
    this.errorMessage,
  });

  factory PlumeWalletData.fromJson(Map<String, dynamic> json) {
    try {
      return PlumeWalletData(
        walletAddress: json['walletAddress'] as String?,
        balance: PlumeStatsData._parseDouble(json['balance']),
        predictions: (json['predictions'] as List?)?.map((item) => 
          PredictionData.fromJson(item as Map<String, dynamic>)
        ).toList(),
        portfolioStats: json['portfolioStats'] as Map<String, dynamic>?,
        activityHistory: json['activityHistory'] as Map<String, dynamic>?,
        rewards: json['rewards'] as Map<String, dynamic>?,
        rankings: json['rankings'] as Map<String, dynamic>?,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error parsing PlumeWalletData: $e');
      return PlumeWalletData.error('Failed to parse wallet data: $e');
    }
  }

  factory PlumeWalletData.error(String message) {
    return PlumeWalletData(
      lastUpdated: DateTime.now(),
      isError: true,
      errorMessage: message,
    );
  }

  @override
  String toString() {
    if (isError) {
      return 'PlumeWalletData.error($errorMessage)';
    }
    return 'PlumeWalletData(address: $walletAddress, balance: $balance, predictions: ${predictions?.length})';
  }
}

class PredictionData {
  final String? id;
  final String? market;
  final String? prediction;
  final double? stake;
  final String? status;
  final DateTime? createdAt;
  final Map<String, dynamic>? outcome;
  final double? payout;
  final bool? isWinning;

  const PredictionData({
    this.id,
    this.market,
    this.prediction,
    this.stake,
    this.status,
    this.createdAt,
    this.outcome,
    this.payout,
    this.isWinning,
  });

  factory PredictionData.fromJson(Map<String, dynamic> json) {
    return PredictionData(
      id: json['id'] as String?,
      market: json['market'] as String?,
      prediction: json['prediction'] as String?,
      stake: PlumeStatsData._parseDouble(json['stake']),
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      outcome: json['outcome'] as Map<String, dynamic>?,
      payout: PlumeStatsData._parseDouble(json['payout']),
      isWinning: json['isWinning'] as bool?,
    );
  }
}

class TokenBalance {
  final String symbol;
  final String tokenAddress;
  final double balance;
  final double usdValue;
  final int decimals;
  final String? logoURI;
  final String? name;
  final double? price;

  const TokenBalance({
    required this.symbol,
    required this.tokenAddress,
    required this.balance,
    required this.usdValue,
    required this.decimals,
    this.logoURI,
    this.name,
    this.price,
  });

  factory TokenBalance.fromJson(Map<String, dynamic> json) {
    return TokenBalance(
      symbol: json['symbol'] as String? ?? 'UNKNOWN',
      tokenAddress: json['tokenAddress'] as String? ?? '',
      balance: PlumeStatsData._parseDouble(json['balance']) ?? 0.0,
      usdValue: PlumeStatsData._parseDouble(json['usdValue']) ?? 0.0,
      decimals: PlumeStatsData._parseInt(json['decimals']) ?? 18,
      logoURI: json['logoURI'] as String?,
      name: json['name'] as String?,
      price: PlumeStatsData._parseDouble(json['price']),
    );
  }

  String get formattedBalance {
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(2)}M';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(2)}K';
    } else if (balance >= 1) {
      return balance.toStringAsFixed(4);
    } else {
      return balance.toStringAsFixed(6);
    }
  }

  String get formattedUsdValue {
    if (usdValue >= 1000000) {
      return '\$${(usdValue / 1000000).toStringAsFixed(2)}M';
    } else if (usdValue >= 1000) {
      return '\$${(usdValue / 1000).toStringAsFixed(2)}K';
    } else if (usdValue >= 1) {
      return '\$${usdValue.toStringAsFixed(2)}';
    } else {
      return '\$${usdValue.toStringAsFixed(4)}';
    }
  }

  bool get hasSignificantValue => usdValue > 0.01;

  @override
  String toString() {
    return 'TokenBalance($symbol: $formattedBalance = $formattedUsdValue)';
  }
}

class WalletBalanceResponse {
  final String walletAddress;
  final double totalUSDValue;
  final List<TokenBalance> tokens;
  final DateTime lastUpdated;
  final bool isError;
  final String? errorMessage;

  const WalletBalanceResponse({
    required this.walletAddress,
    required this.totalUSDValue,
    required this.tokens,
    required this.lastUpdated,
    this.isError = false,
    this.errorMessage,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    try {
      final tokensJson = (json['tokens'] as List?) ?? (json['walletTokenBalanceInfoArr'] as List?);
      final tokens = tokensJson?.map((tokenJson) {
        if (tokenJson is Map<String, dynamic>) {
          if (tokenJson.containsKey('token') && tokenJson.containsKey('holdings')) {
            final tokenInfo = tokenJson['token'] as Map<String, dynamic>;
            final holdingsInfo = tokenJson['holdings'] as Map<String, dynamic>;

            return TokenBalance.fromJson({
              'symbol': tokenInfo['symbol'],
              'name': tokenInfo['name'],
              'tokenAddress': tokenInfo['address'],
              'decimals': tokenInfo['decimals'],
              'logoURI': tokenInfo['imageThumbUrl'] ?? tokenInfo['imageSmallUrl'] ?? tokenInfo['imageLargeUrl'],
              'price': tokenInfo['priceUSD'],
              'balance': holdingsInfo['tokenBalance'],
              'usdValue': holdingsInfo['valueUSD'],
            });
          } else {
            return TokenBalance.fromJson(tokenJson);
          }
        }
        return null;
      }).where((token) => token != null).cast<TokenBalance>().toList() ?? [];

      return WalletBalanceResponse(
        walletAddress: json['walletAddress'] as String? ?? '',
        totalUSDValue: PlumeStatsData._parseDouble(json['totalUSDValueOfWallet']) ?? 0.0,
        tokens: tokens,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error parsing WalletBalanceResponse: $e');
      debugPrint('JSON structure: ${json.toString()}');
      return WalletBalanceResponse.error('Failed to parse wallet balance: $e');
    }
  }

  factory WalletBalanceResponse.error(String message) {
    return WalletBalanceResponse(
      walletAddress: '',
      totalUSDValue: 0.0,
      tokens: [],
      lastUpdated: DateTime.now(),
      isError: true,
      errorMessage: message,
    );
  }

  List<TokenBalance> get tokenBalances => tokens;
  List<TokenBalance> get significantTokens => tokens.where((token) => token.hasSignificantValue).toList();
  List<TokenBalance> get plumeTokens => tokens.where((token) => token.symbol.toUpperCase().contains('PLUME')).toList();
  List<TokenBalance> get topTokensByValue => List<TokenBalance>.from(tokens)..sort((a, b) => b.usdValue.compareTo(a.usdValue));

  int get totalTokenCount => tokens.length;
  int get significantTokenCount => significantTokens.length;
  String get formattedTotalValue => formattedTotalUSDValue;

  String get formattedTotalUSDValue {
    if (totalUSDValue >= 1000000) {
      return '\$${(totalUSDValue / 1000000).toStringAsFixed(2)}M';
    } else if (totalUSDValue >= 1000) {
      return '\$${(totalUSDValue / 1000).toStringAsFixed(2)}K';
    } else {
      return '\$${totalUSDValue.toStringAsFixed(2)}';
    }
  }

  @override
  String toString() {
    if (isError) return 'WalletBalanceResponse.error($errorMessage)';
    return 'WalletBalanceResponse(${tokens.length} tokens, total: $formattedTotalUSDValue)';
  }
}

class PlumeApiService {
  static const String _baseUrl = 'https://portal-api.plume.org/api/v1';
  static const Duration _timeout = Duration(seconds: 15);

  static final PlumeApiService _instance = PlumeApiService._internal();
  factory PlumeApiService() => _instance;
  PlumeApiService._internal();

  final Map<String, PlumeStatsData> _cache = {};
  final Map<String, DateTime> _cacheTimestamp = {};

  final Map<String, PlumeWalletData> _walletCache = {};
  final Map<String, DateTime> _walletCacheTimestamp = {};

  final Map<String, PortalWalletStatsResponse> _walletStatsCache = {};
  final Map<String, DateTime> _walletStatsCacheTimestamp = {};

  final Map<String, BadgesResponse> _badgesCache = {};
  final Map<String, DateTime> _badgesCacheTimestamp = {};

  final Map<String, SkySocietyResponse> _skySocietyCache = {};
  final Map<String, DateTime> _skySocietyCacheTimestamp = {};

  final Map<String, WalletBalanceResponse> _walletBalanceCache = {};
  final Map<String, DateTime> _walletBalanceCacheTimestamp = {};

  final Map<String, DailySpinResponse> _dailySpinCache = {};
  final Map<String, DateTime> _dailySpinCacheTimestamp = {};

  static const Duration _cacheDuration = Duration(minutes: 2);

  Future<PlumeStatsData> getPortalStats(String walletAddress) async {
    if (walletAddress.isEmpty) {
      return PlumeStatsData.error('Wallet address is empty');
    }

    if (!_isValidWalletAddress(walletAddress)) {
      return PlumeStatsData.error('Invalid wallet address format');
    }

    final cachedData = _getCachedData(walletAddress);
    if (cachedData != null) {
      debugPrint('📊 Using cached Plume stats for ${_shortenAddress(walletAddress)}');
      return cachedData;
    }

    try {
      debugPrint('📊 Fetching Plume stats for ${_shortenAddress(walletAddress)}...');

      final url = Uri.parse('$_baseUrl/stats/pp-totals?walletAddress=$walletAddress');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'PlumeVelocity/1.0',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final statsData = PlumeStatsData.fromJson(jsonData);

        _cacheData(walletAddress, statsData);

        debugPrint('✅ Plume stats loaded successfully: $statsData');
        return statsData;

      } else if (response.statusCode == 404) {
        final errorData = PlumeStatsData.error('Wallet not found or no portal activity');
        _cacheData(walletAddress, errorData);
        return errorData;

      } else if (response.statusCode == 429) {
        return PlumeStatsData.error('Too many requests - please wait');

      } else {
        final errorData = PlumeStatsData.error('Server error: ${response.statusCode}');
        debugPrint('❌ Plume API error: ${response.statusCode} - ${response.body}');
        return errorData;
      }

    } on TimeoutException catch (_) {
      return PlumeStatsData.error('Request timeout - check your connection');

    } on http.ClientException catch (e) {
      debugPrint('❌ Plume API client error: $e');
      return PlumeStatsData.error('Connection error: ${e.message}');

    } catch (e) {
      debugPrint('❌ Unexpected error in Plume API: $e');
      return PlumeStatsData.error('Unexpected error: $e');
    }
  }

  bool _isValidWalletAddress(String address) {
    final ethAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return ethAddressRegex.hasMatch(address);
  }

  String _shortenAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  PlumeStatsData? _getCachedData(String walletAddress) {
    final cachedData = _cache[walletAddress];
    final cacheTime = _cacheTimestamp[walletAddress];

    if (cachedData != null && cacheTime != null) {
      final isStale = DateTime.now().difference(cacheTime) > _cacheDuration;
      if (!isStale) {
        return cachedData;
      } else {
        _cache.remove(walletAddress);
        _cacheTimestamp.remove(walletAddress);
      }
    }

    return null;
  }

  void _cacheData(String walletAddress, PlumeStatsData data) {
    _cache[walletAddress] = data;
    _cacheTimestamp[walletAddress] = DateTime.now();

    if (_cache.length > 10) {
      final oldestKey = _cacheTimestamp.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _cache.remove(oldestKey);
      _cacheTimestamp.remove(oldestKey);
    }
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamp.clear();
    debugPrint('🧹 Plume API cache cleared');
  }

  Future<PlumeStatsData> refreshPortalStats(String walletAddress) async {
    _cache.remove(walletAddress);
    _cacheTimestamp.remove(walletAddress);
    return getPortalStats(walletAddress);
  }

  Future<PpScores?> fetchPpTotals(String walletAddress, {bool forceRefresh = false}) async {
    if (walletAddress.isEmpty) {
      debugPrint('❌ fetchPpTotals: Wallet address is empty');
      return null;
    }

    if (!_isValidWalletAddress(walletAddress)) {
      debugPrint('❌ fetchPpTotals: Invalid wallet address format');
      return null;
    }

    if (!forceRefresh) {
      final cacheService = CacheService.instance;
      if (cacheService.isPpScoresCacheValid(walletAddress)) {
        final cachedJson = cacheService.getPpScores(walletAddress);
        if (cachedJson != null) {
          try {
            final jsonData = json.decode(cachedJson);
            if (jsonData['data'] != null && jsonData['data']['ppScores'] != null) {
              final ppScores = PpScores.fromJson(jsonData['data']['ppScores']);
              debugPrint('👍 Using persistent cached PP scores for ${_shortenAddress(walletAddress)}');
              return ppScores;
            }
          } catch (e) {
            debugPrint('❌ Error parsing cached PP scores: $e');
            await cacheService.clearPpScoresCache(walletAddress);
          }
        }
      }
    }

    try {
      debugPrint('🔄 Fetching pp-totals data for ${_shortenAddress(walletAddress)}...');

      final url = Uri.parse('$_baseUrl/stats/pp-totals?walletAddress=$walletAddress');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'PlumeVelocity/1.0',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint('✅ PP-Totals raw response: ${jsonData.toString()}');

        if (jsonData['data'] != null && jsonData['data']['ppScores'] != null) {
          final ppScores = PpScores.fromJson(jsonData['data']['ppScores']);

          final cacheService = CacheService.instance;
          await cacheService.savePpScores(walletAddress, response.body);

          debugPrint('✅ PP-Totals data loaded and cached successfully');
          return ppScores;
        } else {
          debugPrint('❌ PP-Totals: Invalid response structure');
          return null;
        }

      } else if (response.statusCode == 404) {
        debugPrint('❌ PP-Totals: Wallet not found or no data available');
        return null;

      } else {
        debugPrint('❌ PP-Totals API error: ${response.statusCode} - ${response.body}');
        return null;
      }

    } on TimeoutException catch (_) {
      debugPrint('❌ PP-Totals request timeout');
      return null;

    } on http.ClientException catch (e) {
      debugPrint('❌ PP-Totals client error: $e');
      return null;

    } catch (e) {
      debugPrint('❌ Unexpected error in PP-Totals: $e');
      return null;
    }
  }

  Future<PlumeWalletData> getWalletDetails(String walletAddress) async {
    if (walletAddress.isEmpty) {
      return PlumeWalletData.error('Wallet address is empty');
    }

    if (!_isValidWalletAddress(walletAddress)) {
      return PlumeWalletData.error('Invalid wallet address format');
    }

    final cachedData = _getCachedWalletData(walletAddress);
    if (cachedData != null) {
      debugPrint('🏦 Using cached wallet details for ${_shortenAddress(walletAddress)}');
      return cachedData;
    }

    try {
      debugPrint('🏦 Fetching wallet details for ${_shortenAddress(walletAddress)}...');

      final hasConnectivity = await _checkNetworkConnectivity();
      if (!hasConnectivity) {
        debugPrint('❌ No network connectivity - cannot fetch wallet details');
        return PlumeWalletData.error('No internet connection. Please check your network settings.');
      }

      final url = Uri.parse('$_baseUrl/stats/wallet?walletAddress=$walletAddress');
      debugPrint('🔗 Wallet API URL: $url');
      debugPrint('📱 Device type: ${Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Other'}');

      final response = await _makeRequestWithRetry(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final walletData = PlumeWalletData.fromJson(jsonData);

        _cacheWalletData(walletAddress, walletData);

        debugPrint('✅ Wallet details loaded successfully: $walletData');
        return walletData;

      } else if (response.statusCode == 404) {
        final errorData = PlumeWalletData.error('Wallet not found or no portal activity');
        _cacheWalletData(walletAddress, errorData);
        return errorData;

      } else if (response.statusCode == 429) {
        return PlumeWalletData.error('Too many requests - please wait');

      } else {
        final errorData = PlumeWalletData.error('Server error: ${response.statusCode}');
        debugPrint('❌ Wallet API error: ${response.statusCode} - ${response.body}');
        return errorData;
      }

    } on TimeoutException catch (_) {
      return PlumeWalletData.error('Request timeout - check your connection');

    } on SocketException catch (e) {
      debugPrint('❌ Network connection error (Physical Device): $e');
      return PlumeWalletData.error('No internet connection. Please check your device\'s network settings and try again.');

    } on http.ClientException catch (e) {
      debugPrint('❌ Wallet API client error: $e');
      return PlumeWalletData.error('Network error. Please check your internet connection and try again.');

    } on HandshakeException catch (e) {
      debugPrint('❌ SSL/TLS error: $e');
      return PlumeWalletData.error('Security certificate error. Please try again or contact support.');

    } catch (e) {
      debugPrint('❌ Unexpected error in Wallet API: $e');
      debugPrint('📱 Device info: ${Platform.operatingSystem}');
      return PlumeWalletData.error('Unable to load data. Please check your internet connection and try again.');
    }
  }

  PlumeWalletData? _getCachedWalletData(String walletAddress) {
    final cachedData = _walletCache[walletAddress];
    final cacheTime = _walletCacheTimestamp[walletAddress];

    if (cachedData != null && cacheTime != null) {
      final isStale = DateTime.now().difference(cacheTime) > _cacheDuration;
      if (!isStale) {
        return cachedData;
      } else {
        _walletCache.remove(walletAddress);
        _walletCacheTimestamp.remove(walletAddress);
      }
    }

    return null;
  }

  void _cacheWalletData(String walletAddress, PlumeWalletData data) {
    _walletCache[walletAddress] = data;
    _walletCacheTimestamp[walletAddress] = DateTime.now();

    if (_walletCache.length > 10) {
      final oldestKey = _walletCacheTimestamp.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _walletCache.remove(oldestKey);
      _walletCacheTimestamp.remove(oldestKey);
    }
  }

  Future<PlumeWalletData> refreshWalletDetails(String walletAddress) async {
    _walletCache.remove(walletAddress);
    _walletCacheTimestamp.remove(walletAddress);
    return getWalletDetails(walletAddress);
  }

  Future<bool> _checkNetworkConnectivity() async {
    try {
      debugPrint('📶 Checking network connectivity...');

      final lookup = await InternetAddress.lookup('portal-api.plume.org');

      if (lookup.isNotEmpty) {
        debugPrint('✅ Network connectivity check passed');
        return true;
      } else {
        debugPrint('❌ Network connectivity check failed - DNS resolution failed');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Network connectivity check failed: $e');
      return false;
    }
  }

  Future<http.Response> _makeRequestWithRetry(Uri url, {int maxRetries = 3}) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        debugPrint('🔄 Network request attempt ${attempt + 1}/$maxRetries to $url');

        final response = await http.get(
          url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'User-Agent': 'PlumeVelocity/1.0',
            'Cache-Control': 'no-cache',
          },
        ).timeout(_timeout);

        debugPrint('✅ Request successful on attempt ${attempt + 1}');
        return response;

      } on SocketException catch (e) {
        attempt++;
        debugPrint('📱 Network error on attempt $attempt: $e');

        if (attempt >= maxRetries) {
          debugPrint('😰 All retry attempts failed for network connection');
          rethrow;
        }

        final waitTime = math.pow(2, attempt).toInt();
        debugPrint('⏳ Waiting ${waitTime}s before retry...');
        await Future.delayed(Duration(seconds: waitTime));

      } on TimeoutException catch (e) {
        attempt++;
        debugPrint('⏱️ Timeout on attempt $attempt: $e');

        if (attempt >= maxRetries) {
          debugPrint('😰 All retry attempts failed for timeout');
          rethrow;
        }

        await Future.delayed(Duration(seconds: attempt * 2));

      } catch (e) {
        debugPrint('❌ Non-retryable error: $e');
        rethrow;
      }
    }

    throw Exception('Maximum retry attempts exceeded');
  }

  Future<PortalWalletStatsResponse?> getComprehensiveWalletStats(String walletAddress, {bool forceRefresh = false}) async {
    if (walletAddress.isEmpty) {
      debugPrint('❌ Empty wallet address provided');
      return null;
    }

    if (!_isValidWalletAddress(walletAddress)) {
      debugPrint('❌ Invalid wallet address format: $walletAddress');
      return null;
    }

    if (!forceRefresh) {
      final cacheService = CacheService.instance;
      if (cacheService.isWalletDataCacheValid(walletAddress)) {
        final cachedJson = cacheService.getWalletData(walletAddress);
        if (cachedJson != null) {
          try {
            final jsonData = json.decode(cachedJson);
            final cachedResponse = PortalWalletStatsResponse.fromJson(jsonData);
            debugPrint('📊 Using persistent cached comprehensive wallet stats for ${_shortenAddress(walletAddress)}');
            return cachedResponse;
          } catch (e) {
            debugPrint('❌ Error parsing cached data: $e');
            await cacheService.clearWalletDataCache(walletAddress);
          }
        }
      }
    }

    if (!forceRefresh) {
      final cachedData = _getCachedWalletStats(walletAddress);
      if (cachedData != null) {
        debugPrint('📊 Using memory cached comprehensive wallet stats for ${_shortenAddress(walletAddress)}');
        return cachedData;
      }
    }

    try {
      debugPrint('📊 Fetching comprehensive wallet stats for ${_shortenAddress(walletAddress)}...');

      final hasConnectivity = await _checkNetworkConnectivity();
      if (!hasConnectivity) {
        debugPrint('❌ No network connectivity detected - aborting API call');
        return null;
      }

      final url = Uri.parse('$_baseUrl/stats/wallet?walletAddress=$walletAddress');
      debugPrint('🔗 API URL: $url');
      debugPrint('📱 Running on physical device: ${!kIsWeb && (Platform.isAndroid || Platform.isIOS)}');

      final response = await _makeRequestWithRetry(url);

      debugPrint('📊 Portal API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        debugPrint('📊 Raw Portal API response: ${json.encode(jsonData)}');

        final walletStatsResponse = PortalWalletStatsResponse.fromJson(jsonData);

        _cacheWalletStats(walletAddress, walletStatsResponse);

        final cacheService = CacheService.instance;
        await cacheService.saveWalletData(walletAddress, response.body);

        final stats = walletStatsResponse.data.stats;
        debugPrint('🎯 Comprehensive Portal Stats Summary:');
        debugPrint('   💰 Financial: TVL ${stats.formattedTvl}, Bridged ${stats.formattedBridgedTotal}, Swaps: ${stats.swapCount}');
        debugPrint('   🏆 XP: ${stats.formattedTotalXp} (Rank: ${stats.formattedXpRank})');
        debugPrint('   🚀 Activity: ${stats.protocolsUsed} protocols, ${stats.completedQuests} quests, ${stats.dailySpinStreak} spin streak');
        debugPrint('   💎 Staking: ${stats.formattedPlumeStaked}, Streak: ${stats.plumeStakingStreak} days');
        debugPrint('   👥 Social: ${stats.referralCount} referrals, Code: ${stats.referralCode}');
        debugPrint('   🎮 Top Protocols: ${stats.topProtocols.take(3).map((p) => '${p.displayName} (${p.daysUsed}d)').join(', ')}');
        debugPrint('   📊 Engagement: ${stats.activityLevel}');

        debugPrint('✅ Comprehensive wallet stats loaded successfully');
        return walletStatsResponse;

      } else if (response.statusCode == 404) {
        debugPrint('⚠️ Wallet not found or no portal activity for ${_shortenAddress(walletAddress)}');
        return null;

      } else if (response.statusCode == 429) {
        debugPrint('⏳ Rate limit exceeded for Portal API');
        return null;

      } else {
        debugPrint('❌ Portal API error: ${response.statusCode} - ${response.body}');
        return null;
      }

    } on TimeoutException catch (_) {
      debugPrint('⏱️ Portal API request timeout for ${_shortenAddress(walletAddress)}');
      return null;

    } on SocketException catch (e) {
      debugPrint('❌ Network connection error (Physical Device): $e');
      debugPrint('📱 Check device internet connection and firewall settings');
      return null;

    } on http.ClientException catch (e) {
      debugPrint('❌ Portal API client error: $e');
      debugPrint('📱 This often happens on physical devices - check network permissions');
      return null;

    } on HandshakeException catch (e) {
      debugPrint('❌ SSL/TLS handshake error (Physical Device): $e');
      debugPrint('📱 Certificate or HTTPS configuration issue');
      return null;

    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error in comprehensive Portal API: $e');
      debugPrint('📱 Full error details: $stackTrace');
      debugPrint('📱 Device info: Platform=${Platform.operatingSystem}, isPhysical=${!kIsWeb && (Platform.isAndroid || Platform.isIOS)}');
      return null;
    }
  }

  PortalWalletStatsResponse? _getCachedWalletStats(String walletAddress) {
    final cachedData = _walletStatsCache[walletAddress];
    final cacheTime = _walletStatsCacheTimestamp[walletAddress];

    if (cachedData != null && cacheTime != null) {
      final isStale = DateTime.now().difference(cacheTime) > _cacheDuration;
      if (!isStale) {
        return cachedData;
      } else {
        _walletStatsCache.remove(walletAddress);
        _walletStatsCacheTimestamp.remove(walletAddress);
      }
    }

    return null;
  }

  void _cacheWalletStats(String walletAddress, PortalWalletStatsResponse data) {
    _walletStatsCache[walletAddress] = data;
    _walletStatsCacheTimestamp[walletAddress] = DateTime.now();

    if (_walletStatsCache.length > 10) {
      final oldestKey = _walletStatsCacheTimestamp.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _walletStatsCache.remove(oldestKey);
      _walletStatsCacheTimestamp.remove(oldestKey);
    }
  }

  Future<PortalWalletStatsResponse?> refreshComprehensiveWalletStats(String walletAddress) async {
    _walletStatsCache.remove(walletAddress);
    _walletStatsCacheTimestamp.remove(walletAddress);
    return getComprehensiveWalletStats(walletAddress);
  }

  Future<BadgesResponse?> getBadges(String walletAddress) async {
    if (walletAddress.isEmpty) {
      debugPrint('❌ getBadges: Wallet address is empty');
      return null;
    }

    if (!_isValidWalletAddress(walletAddress)) {
      debugPrint('❌ getBadges: Invalid wallet address format');
      return null;
    }

    final cachedData = _getCachedBadges(walletAddress);
    if (cachedData != null) {
      debugPrint('🏅 Using cached badges for ${_shortenAddress(walletAddress)}');
      return cachedData;
    }

    try {
      debugPrint('🏅 Fetching badges for ${_shortenAddress(walletAddress)}...');

      final url = Uri.parse('$_baseUrl/badges?walletAddress=$walletAddress');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'PlumeVelocity/1.0',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint('✅ Badges raw response: ${jsonData.toString()}');

        final badgesResponse = BadgesResponse.fromJson(jsonData);

        _cacheBadges(walletAddress, badgesResponse);

        final badgesData = badgesResponse.data;
        debugPrint('🎯 Badges Summary:');
        debugPrint('   🏅 Total badges: ${badgesData.badges.length}');
        debugPrint('   ✅ Earned badges: ${badgesData.earnedBadges.length}');
        debugPrint('   💎 Total PP from badges: ${badgesData.totalPlumePoints}');
        debugPrint('   📋 Quest badges: ${badgesData.questBadges.length}');
        debugPrint('   👑 Role badges: ${badgesData.roleBadges.length}');
        debugPrint('   🎉 Event badges: ${badgesData.eventBadges.length}');
        debugPrint('   🛡️ Guardian badges: ${badgesData.guardianBadges.length}');

        debugPrint('✅ Badges loaded successfully');
        return badgesResponse;

      } else if (response.statusCode == 404) {
        debugPrint('⚠️ No badges found for ${_shortenAddress(walletAddress)}');
        return null;

      } else if (response.statusCode == 429) {
        debugPrint('⏳ Rate limit exceeded for Badges API');
        return null;

      } else {
        debugPrint('❌ Badges API error: ${response.statusCode} - ${response.body}');
        return null;
      }

    } on TimeoutException catch (_) {
      debugPrint('⏱️ Badges API request timeout for ${_shortenAddress(walletAddress)}');
      return null;

    } on http.ClientException catch (e) {
      debugPrint('❌ Badges API client error: $e');
      return null;

    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error in Badges API: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  BadgesResponse? _getCachedBadges(String walletAddress) {
    final cachedData = _badgesCache[walletAddress];
    final cacheTime = _badgesCacheTimestamp[walletAddress];

    if (cachedData != null && cacheTime != null) {
      final isStale = DateTime.now().difference(cacheTime) > _cacheDuration;
      if (!isStale) {
        return cachedData;
      } else {
        _badgesCache.remove(walletAddress);
        _badgesCacheTimestamp.remove(walletAddress);
      }
    }

    return null;
  }

  void _cacheBadges(String walletAddress, BadgesResponse data) {
    _badgesCache[walletAddress] = data;
    _badgesCacheTimestamp[walletAddress] = DateTime.now();

    if (_badgesCache.length > 10) {
      final oldestKey = _badgesCacheTimestamp.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _badgesCache.remove(oldestKey);
      _badgesCacheTimestamp.remove(oldestKey);
    }
  }

  Future<BadgesResponse?> refreshBadges(String walletAddress) async {
    _badgesCache.remove(walletAddress);
    _badgesCacheTimestamp.remove(walletAddress);
    return getBadges(walletAddress);
  }

  Future<SkySocietyResponse?> getSkyScietyData(String walletAddress, {bool forceRefresh = false}) async {
    if (walletAddress.isEmpty) {
      debugPrint('❌ getSkyScietyData: Wallet address is empty');
      return null;
    }

    if (!_isValidWalletAddress(walletAddress)) {
      debugPrint('❌ getSkyScietyData: Invalid wallet address format');
      return null;
    }

    if (!forceRefresh) {
      final cacheService = CacheService.instance;
      if (cacheService.isSkySocietyCacheValid(walletAddress)) {
        final cachedJson = cacheService.getSkySociety(walletAddress);
        if (cachedJson != null) {
          try {
            final jsonData = json.decode(cachedJson);
            final cachedResponse = SkySocietyResponse.fromJson(jsonData);
            debugPrint('🌟 Using persistent cached Sky Society data for ${_shortenAddress(walletAddress)}');
            return cachedResponse;
          } catch (e) {
            debugPrint('❌ Error parsing cached Sky Society data: $e');
            await cacheService.clearSkySocietyCache(walletAddress);
          }
        }
      }
    }

    if (!forceRefresh) {
      final cachedData = _getCachedSkySociety(walletAddress);
      if (cachedData != null) {
        debugPrint('🌟 Using memory cached Sky Society data for ${_shortenAddress(walletAddress)}');
        return cachedData;
      }
    }

    try {
      debugPrint('🌟 Fetching Sky Society data for ${_shortenAddress(walletAddress)}...');

      final List<String> endpoints = [
        '$_baseUrl/stats/wallet/$walletAddress', // Main stats endpoint
        '$_baseUrl/user/social-connections?walletAddress=$walletAddress', // Social connections
        '$_baseUrl/sky-society/$walletAddress', // Direct Sky Society endpoint
      ];

      SkySocietyResponse? result;

      for (final endpoint in endpoints) {
        try {
          debugPrint('🔍 Trying Sky Society endpoint: $endpoint');
          final url = Uri.parse(endpoint);

          final response = await http.get(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'User-Agent': 'PlumeVelocity/1.0',
            },
          ).timeout(_timeout);

          debugPrint('📡 Response status: ${response.statusCode}');

          if (response.statusCode == 200) {
            final jsonData = json.decode(response.body);
            debugPrint('✅ Raw response from $endpoint: ${jsonData.toString().substring(0, math.min(500, jsonData.toString().length))}...');

            String? tierData;
            if (jsonData is Map<String, dynamic>) {
              tierData = _extractTierFromResponse(jsonData);

              if (tierData != null) {
                debugPrint('🎯 Found Sky Society tier "$tierData" in endpoint: $endpoint');

                final skySocietyData = SkySocietyData(skySocietyTier: tierData);
                result = SkySocietyResponse(data: skySocietyData);
                break;
              } else {
                debugPrint('❌ No Sky Society tier found in response from: $endpoint');
              }
            }
          } else {
            debugPrint('❌ Endpoint $endpoint returned status: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('❌ Error trying endpoint $endpoint: $e');
          continue;
        }
      }

      if (result != null) {
        _cacheSkySociety(walletAddress, result);

        final cacheService = CacheService.instance;
        final cacheData = {
          'data': {
            'skySocietyTier': result.data.skySocietyTier,
          }
        };
        await cacheService.saveSkySociety(walletAddress, json.encode(cacheData));

        final skySocietyData = result.data;
        debugPrint('🎯 Final Sky Society Summary:');
        debugPrint('   ⭐ Tier: ${skySocietyData.skySocietyTier}');
        debugPrint('   💫 Has tier: ${skySocietyData.skySocietyTier != null}');

        debugPrint('✅ Sky Society data loaded and cached successfully');
        return result;
      } else {
        debugPrint('❌ No Sky Society tier data found in any endpoint');
        return null;
      }

    } on TimeoutException catch (_) {
      debugPrint('⏱️ Sky Society API request timeout for ${_shortenAddress(walletAddress)}');
      return null;

    } on http.ClientException catch (e) {
      debugPrint('❌ Sky Society API client error: $e');
      return null;

    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error in Sky Society API: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  SkySocietyResponse? _getCachedSkySociety(String walletAddress) {
    final cachedData = _skySocietyCache[walletAddress];
    final cacheTime = _skySocietyCacheTimestamp[walletAddress];

    if (cachedData != null && cacheTime != null) {
      final isStale = DateTime.now().difference(cacheTime) > _cacheDuration;
      if (!isStale) {
        return cachedData;
      } else {
        _skySocietyCache.remove(walletAddress);
        _skySocietyCacheTimestamp.remove(walletAddress);
      }
    }

    return null;
  }

  void _cacheSkySociety(String walletAddress, SkySocietyResponse data) {
    _skySocietyCache[walletAddress] = data;
    _skySocietyCacheTimestamp[walletAddress] = DateTime.now();

    if (_skySocietyCache.length > 10) {
      final oldestKey = _skySocietyCacheTimestamp.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _skySocietyCache.remove(oldestKey);
      _skySocietyCacheTimestamp.remove(oldestKey);
    }
  }

  Future<SkySocietyResponse?> refreshSkySociety(String walletAddress) async {
    _skySocietyCache.remove(walletAddress);
    _skySocietyCacheTimestamp.remove(walletAddress);
    return getSkyScietyData(walletAddress);
  }

  String? _extractTierFromResponse(Map<String, dynamic> jsonData) {
    if (jsonData['skySocietyTier'] is String) {
      return jsonData['skySocietyTier'] as String;
    }

    if (jsonData['displayTier'] is String) {
      return jsonData['displayTier'] as String;
    }

    if (jsonData['data'] is Map<String, dynamic>) {
      final dataObj = jsonData['data'] as Map<String, dynamic>;

      if (dataObj['skySocietyTier'] is String) {
        return dataObj['skySocietyTier'] as String;
      }

      if (dataObj['displayTier'] is String) {
        return dataObj['displayTier'] as String;
      }

      if (dataObj['data'] is Map<String, dynamic>) {
        final nestedData = dataObj['data'] as Map<String, dynamic>;
        if (nestedData['skySocietyTier'] is String) {
          return nestedData['skySocietyTier'] as String;
        }
        if (nestedData['displayTier'] is String) {
          return nestedData['displayTier'] as String;
        }
      }

      if (dataObj['stats'] is Map<String, dynamic>) {
        final statsObj = dataObj['stats'] as Map<String, dynamic>;
        if (statsObj['skySocietyTier'] is String) {
          return statsObj['skySocietyTier'] as String;
        }
        if (statsObj['displayTier'] is String) {
          return statsObj['displayTier'] as String;
        }
      }
    }

    if (jsonData['stats'] is Map<String, dynamic>) {
      final statsObj = jsonData['stats'] as Map<String, dynamic>;
      if (statsObj['skySocietyTier'] is String) {
        return statsObj['skySocietyTier'] as String;
      }
      if (statsObj['displayTier'] is String) {
        return statsObj['displayTier'] as String;
      }
    }

    return null;
  }

  Future<WalletBalanceResponse?> getWalletBalance(String walletAddress, {bool forceRefresh = false}) async {
    if (walletAddress.isEmpty) {
      debugPrint('❌ getWalletBalance: Wallet address is empty');
      return null;
    }

    if (!_isValidWalletAddress(walletAddress)) {
      debugPrint('❌ getWalletBalance: Invalid wallet address format');
      return null;
    }

    if (!forceRefresh) {
      final cacheService = CacheService.instance;
      if (cacheService.isWalletBalanceCacheValid(walletAddress)) {
        final cachedJson = cacheService.getWalletBalance(walletAddress);
        if (cachedJson != null) {
          try {
            final jsonData = json.decode(cachedJson);
            final cachedResponse = WalletBalanceResponse.fromJson(jsonData);
            debugPrint('💰 Using persistent cached wallet balance for ${_shortenAddress(walletAddress)}');
            return cachedResponse;
          } catch (e) {
            debugPrint('❌ Error parsing cached wallet balance: $e');
            await cacheService.clearWalletBalanceCache(walletAddress);
          }
        }
      }
    }

    if (!forceRefresh) {
      final cachedData = _getCachedWalletBalance(walletAddress);
      if (cachedData != null) {
        debugPrint('💰 Using memory cached wallet balance for ${_shortenAddress(walletAddress)}');
        return cachedData;
      }
    }

    try {
      debugPrint('💰 Fetching wallet balance for ${_shortenAddress(walletAddress)}...');

      final url = Uri.parse('$_baseUrl/wallet-balance?walletAddress=$walletAddress');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'PlumeVelocity/1.0',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint('✅ Wallet Balance raw response: ${jsonData.toString()}');

        debugPrint('🔍 Parsing wallet balance response...');
        debugPrint('   Has totalUSDValueOfWallet: ${jsonData.containsKey('totalUSDValueOfWallet')}');
        debugPrint('   Has walletTokenBalanceInfoArr: ${jsonData.containsKey('walletTokenBalanceInfoArr')}');
        if (jsonData.containsKey('walletTokenBalanceInfoArr')) {
          final tokenArray = jsonData['walletTokenBalanceInfoArr'] as List?;
          debugPrint('   Token array length: ${tokenArray?.length ?? 0}');
          if (tokenArray != null && tokenArray.isNotEmpty) {
            debugPrint('   First token structure: ${tokenArray.first}');
          }
        }

        final walletBalanceResponse = WalletBalanceResponse.fromJson(jsonData);

        _cacheWalletBalance(walletAddress, walletBalanceResponse);

        final cacheService = CacheService.instance;
        await cacheService.saveWalletBalance(walletAddress, response.body);

        debugPrint('🎯 Wallet Balance Summary:');
        debugPrint('   💰 Total USD Value: ${walletBalanceResponse.formattedTotalUSDValue}');
        debugPrint('   🪙 Total Tokens: ${walletBalanceResponse.tokens.length}');
        debugPrint('   💎 Significant Tokens: ${walletBalanceResponse.significantTokens.length}');
        debugPrint('   🔥 PLUME Tokens: ${walletBalanceResponse.plumeTokens.length}');
        debugPrint('   🏆 Top 3 Tokens: ${walletBalanceResponse.topTokensByValue.take(3).map((t) => '${t.symbol} (${t.formattedUsdValue})').join(', ')}');

        debugPrint('✅ Wallet Balance loaded successfully');
        return walletBalanceResponse;

      } else if (response.statusCode == 404) {
        debugPrint('⚠️ No wallet balance found for ${_shortenAddress(walletAddress)}');
        return null;

      } else if (response.statusCode == 429) {
        debugPrint('⏳ Rate limit exceeded for Wallet Balance API');
        return null;

      } else {
        debugPrint('❌ Wallet Balance API error: ${response.statusCode} - ${response.body}');
        return null;
      }

    } on TimeoutException catch (_) {
      debugPrint('⏱️ Wallet Balance API request timeout for ${_shortenAddress(walletAddress)}');
      return null;

    } on http.ClientException catch (e) {
      debugPrint('❌ Wallet Balance API client error: $e');
      return null;

    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error in Wallet Balance API: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  WalletBalanceResponse? _getCachedWalletBalance(String walletAddress) {
    final cachedData = _walletBalanceCache[walletAddress];
    final cacheTime = _walletBalanceCacheTimestamp[walletAddress];

    if (cachedData != null && cacheTime != null) {
      final isStale = DateTime.now().difference(cacheTime) > _cacheDuration;
      if (!isStale) {
        return cachedData;
      } else {
        _walletBalanceCache.remove(walletAddress);
        _walletBalanceCacheTimestamp.remove(walletAddress);
      }
    }

    return null;
  }

  void _cacheWalletBalance(String walletAddress, WalletBalanceResponse data) {
    _walletBalanceCache[walletAddress] = data;
    _walletBalanceCacheTimestamp[walletAddress] = DateTime.now();

    if (_walletBalanceCache.length > 10) {
      final oldestKey = _walletBalanceCacheTimestamp.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _walletBalanceCache.remove(oldestKey);
      _walletBalanceCacheTimestamp.remove(oldestKey);
    }
  }

  Future<WalletBalanceResponse?> refreshWalletBalance(String walletAddress) async {
    _walletBalanceCache.remove(walletAddress);
    _walletBalanceCacheTimestamp.remove(walletAddress);
    return getWalletBalance(walletAddress);
  }

  Future<int> getTransactionCount(String walletAddress) async {
    if (walletAddress.isEmpty) {
      debugPrint('❌ getTransactionCount: Wallet address is empty');
      return 0;
    }

    if (!_isValidWalletAddress(walletAddress)) {
      debugPrint('❌ getTransactionCount: Invalid wallet address format');
      return 0;
    }

    try {
      debugPrint('🔍 Fetching actual blockchain transaction count (nonce) for ${_shortenAddress(walletAddress)}...');

      final client = Web3Client('https://rpc.plume.org/', http.Client());
      final address = EthereumAddress.fromHex(walletAddress);

      final nonce = await client.getTransactionCount(address).timeout(const Duration(seconds: 15));

      debugPrint('✅ Found $nonce actual blockchain transactions (nonce) for ${_shortenAddress(walletAddress)}');
      client.dispose();
      return nonce;

    } on TimeoutException catch (_) {
      debugPrint('⏱️ Blockchain RPC request timeout - falling back to explorer method');
      return await _getTransactionCountFromExplorer(walletAddress);

    } on http.ClientException catch (e) {
      debugPrint('❌ Blockchain RPC client error: $e - falling back to explorer method');
      return await _getTransactionCountFromExplorer(walletAddress);

    } catch (e) {
      debugPrint('❌ Unexpected error getting blockchain nonce: $e - falling back to explorer method');
      return await _getTransactionCountFromExplorer(walletAddress);
    }
  }

  Future<int> _getTransactionCountFromExplorer(String walletAddress) async {
    try {
      debugPrint('🔍 Fallback: Fetching transaction count from Plume Explorer for ${_shortenAddress(walletAddress)}...');

      final url = Uri.parse('https://explorer.plume.org/api/v2/addresses/$walletAddress/transactions?filter=to%20%7C%20from');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'PlumeVelocity/1.0',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        int totalTxCount = 0;

        if (jsonData['total_count'] != null) {
          totalTxCount = jsonData['total_count'] as int? ?? 0;
        } else if (jsonData['totalCount'] != null) {
          totalTxCount = jsonData['totalCount'] as int? ?? 0;
        } else if (jsonData['count'] != null) {
          totalTxCount = jsonData['count'] as int? ?? 0;
        } else if (jsonData['items'] != null && jsonData['items'] is List) {
          final items = jsonData['items'] as List;
          totalTxCount = items.length;
          debugPrint('⚠️ Only found items array with ${items.length} transactions - this might be paginated');
        }

        debugPrint('✅ Explorer fallback: Found $totalTxCount total transactions');
        return totalTxCount;

      } else {
        debugPrint('❌ Plume Explorer fallback failed: ${response.statusCode}');
        return await _getBlockchainNonceDirectly(walletAddress);
      }

    } catch (e) {
      debugPrint('❌ Explorer fallback error: $e - using direct blockchain nonce');
      return await _getBlockchainNonceDirectly(walletAddress);
    }
  }

  Future<int> _getBlockchainNonceDirectly(String walletAddress) async {
    try {
      debugPrint('🔗 Last resort: Getting blockchain nonce directly for ${_shortenAddress(walletAddress)}');

      final rpcUrls = [
        'https://rpc.plume.org/',
        'https://rpc.plume.network/',
        'https://plume-rpc.plumenetwork.xyz/',
      ];

      for (final rpcUrl in rpcUrls) {
        try {
          final client = Web3Client(rpcUrl, http.Client());
          final address = EthereumAddress.fromHex(walletAddress);
          final nonce = await client.getTransactionCount(address).timeout(const Duration(seconds: 10));
          client.dispose();

          debugPrint('✅ Direct blockchain nonce: $nonce from $rpcUrl');
          return nonce;
        } catch (e) {
          debugPrint('❌ Failed with RPC $rpcUrl: $e');
          continue;
        }
      }

      debugPrint('❌ All RPC endpoints failed - returning 0');
      return 0;

    } catch (e) {
      debugPrint('❌ Final fallback failed: $e');
      return 0;
    }
  }

  Future<int> getBadgeCount(String walletAddress) async {
    final badgesResponse = await getBadges(walletAddress);
    return badgesResponse?.data.earnedBadges.length ?? 0;
  }

  Future<DailySpinResponse?> getDailySpinData(String walletAddress, {bool forceRefresh = false}) async {
    if (walletAddress.isEmpty) {
      debugPrint('❌ getDailySpinData: Wallet address is empty');
      return null;
    }

    if (!_isValidWalletAddress(walletAddress)) {
      debugPrint('❌ getDailySpinData: Invalid wallet address format');
      return null;
    }

    if (!forceRefresh) {
      final cacheService = CacheService.instance;
      if (cacheService.isDailySpinCacheValid(walletAddress)) {
        final cachedJson = cacheService.getDailySpin(walletAddress);
        if (cachedJson != null) {
          try {
            final jsonData = json.decode(cachedJson);
            final cachedResponse = DailySpinResponse.fromJson(jsonData);
            debugPrint('🎰 Using persistent cached daily spin data for ${_shortenAddress(walletAddress)}');
            return cachedResponse;
          } catch (e) {
            debugPrint('❌ Error parsing cached daily spin data: $e');
            await cacheService.clearDailySpinCache(walletAddress);
          }
        }
      }
    }

    if (!forceRefresh) {
      final cachedData = _getCachedDailySpinData(walletAddress);
      if (cachedData != null) {
        debugPrint('🎰 Using memory cached daily spin data for ${_shortenAddress(walletAddress)}');
        return cachedData;
      }
    }

    try {
      debugPrint('🎰 Fetching daily spin data for ${_shortenAddress(walletAddress)}...');

      final url = Uri.parse('$_baseUrl/stats/dailySpinData?walletAddress=$walletAddress');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'PlumeVelocity/1.0',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint('✅ Daily Spin Data raw response: ${jsonData.toString().substring(0, math.min(500, jsonData.toString().length))}...');

        final dailySpinResponse = DailySpinResponse.fromJson(jsonData);

        _cacheDailySpinData(walletAddress, dailySpinResponse);

        final cacheService = CacheService.instance;
        await cacheService.saveDailySpin(walletAddress, response.body);

        final spinData = dailySpinResponse.data;
        debugPrint('🎯 Daily Spin Data Summary:');
        debugPrint('   🎰 Total spins: ${spinData.summary.totalSpins}');
        debugPrint('   ✅ Successful spins: ${spinData.summary.successfulSpins}');
        debugPrint('   💎 Total rewards: ${spinData.summary.formattedTotalRewards}');
        debugPrint('   🔥 Current streak: ${spinData.summary.currentStreak} days');
        debugPrint('   📈 Success rate: ${spinData.summary.formattedSuccessRate}');
        debugPrint('   🎮 Activity level: ${spinData.summary.activityLevel}');
        debugPrint('   📊 Recent spins count: ${spinData.recentSpins.length}');
        debugPrint('   📅 Today spins count: ${spinData.todaySpins.length}');

        debugPrint('✅ Daily Spin Data loaded successfully');
        return dailySpinResponse;

      } else if (response.statusCode == 404) {
        debugPrint('⚠️ No daily spin data found for ${_shortenAddress(walletAddress)}');
        return null;

      } else if (response.statusCode == 429) {
        debugPrint('⏳ Rate limit exceeded for Daily Spin Data API');
        return null;

      } else {
        debugPrint('❌ Daily Spin Data API error: ${response.statusCode} - ${response.body}');
        return null;
      }

    } on TimeoutException catch (_) {
      debugPrint('⏱️ Daily Spin Data API request timeout for ${_shortenAddress(walletAddress)}');
      return null;

    } on http.ClientException catch (e) {
      debugPrint('❌ Daily Spin Data API client error: $e');
      return null;

    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error in Daily Spin Data API: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  DailySpinResponse? _getCachedDailySpinData(String walletAddress) {
    final cachedData = _dailySpinCache[walletAddress];
    final cacheTime = _dailySpinCacheTimestamp[walletAddress];

    if (cachedData != null && cacheTime != null) {
      final isStale = DateTime.now().difference(cacheTime) > _cacheDuration;
      if (!isStale) {
        return cachedData;
      } else {
        _dailySpinCache.remove(walletAddress);
        _dailySpinCacheTimestamp.remove(walletAddress);
      }
    }

    return null;
  }

  void _cacheDailySpinData(String walletAddress, DailySpinResponse data) {
    _dailySpinCache[walletAddress] = data;
    _dailySpinCacheTimestamp[walletAddress] = DateTime.now();

    if (_dailySpinCache.length > 10) {
      final oldestKey = _dailySpinCacheTimestamp.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _dailySpinCache.remove(oldestKey);
      _dailySpinCacheTimestamp.remove(oldestKey);
    }
  }

  Future<DailySpinResponse?> refreshDailySpinData(String walletAddress) async {
    _dailySpinCache.remove(walletAddress);
    _dailySpinCacheTimestamp.remove(walletAddress);
    return getDailySpinData(walletAddress);
  }

  void clearAllCaches() {
    clearCache();
    _walletCache.clear();
    _walletCacheTimestamp.clear();
    _walletStatsCache.clear();
    _walletStatsCacheTimestamp.clear();
    _badgesCache.clear();
    _badgesCacheTimestamp.clear();
    _skySocietyCache.clear();
    _skySocietyCacheTimestamp.clear();
    _walletBalanceCache.clear();
    _walletBalanceCacheTimestamp.clear();
    _dailySpinCache.clear();
    _dailySpinCacheTimestamp.clear();
    _season1Cache.clear();
    _season1CacheTimestamp.clear();
    _season1AllocationCache.clear();
    _season1AllocationCacheTimestamp.clear();
    debugPrint('🧹 All Plume API caches cleared');
  }

  final Map<String, Season1Response> _season1Cache = {};
  final Map<String, DateTime> _season1CacheTimestamp = {};

  final Map<String, Season1AllocationResponse> _season1AllocationCache = {};
  final Map<String, DateTime> _season1AllocationCacheTimestamp = {};

  Future<Season1Response?> getSeason1Data(String walletAddress) async {
    if (walletAddress.isEmpty) {
      debugPrint('❌ Season 1 Data: Wallet address is empty');
      return null;
    }

    final cachedData = _getCachedSeason1Data(walletAddress);
    if (cachedData != null) {
      debugPrint('💾 Season 1 Data: Using cached data for ${_shortenAddress(walletAddress)}');
      return cachedData;
    }

    debugPrint('🛫 Fetching Season 1 data for ${_shortenAddress(walletAddress)}...');

    try {
      final url = '$_baseUrl/stats/season1?walletAddress=$walletAddress';
      debugPrint('🔍 Season 1 API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'PlumePortalFlutter/1.0',
        },
      ).timeout(_timeout);

      debugPrint('📡 Season 1 API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✅ Season 1 raw response: ${response.body}');

        final season1Response = Season1Response.fromJson(jsonData);

        _cacheSeason1Data(walletAddress, season1Response);

        final stats = season1Response.data.season1Stats;
        debugPrint('🎯 Season 1 Summary:');
        debugPrint('   ✈️ Miles: ${stats.formattedMiles}');
        debugPrint('   🎫 Flight Class: ${stats.flightClassDisplay}');
        debugPrint('   📬 Stamps: ${stats.stamps}');
        debugPrint('   👥 Referrals: ${stats.referrals}');
        debugPrint('   📊 Activity Level: ${stats.activityLevel}');
        debugPrint('   📈 Has Data: ${stats.hasData}');

        debugPrint('✅ Season 1 data loaded successfully');
        return season1Response;

      } else if (response.statusCode == 404) {
        debugPrint('⚠️ No Season 1 data found for ${_shortenAddress(walletAddress)}');
        final emptyResponse = Season1Response(
          data: Season1Data(
            season1Stats: Season1Stats(
              miles: 0,
              flightClass: '',
              stamps: 0,
              referrals: 0,
            ),
            walletContext: WalletContext(
              address: walletAddress,
              isAuthenticatedUser: false,
              isAdmin: false,
            ),
          ),
        );
        _cacheSeason1Data(walletAddress, emptyResponse);
        return emptyResponse;

      } else if (response.statusCode == 429) {
        debugPrint('⏳ Rate limit exceeded for Season 1 API');
        return null;

      } else {
        debugPrint('❌ Season 1 API error: ${response.statusCode} - ${response.body}');
        return null;
      }

    } on TimeoutException catch (_) {
      debugPrint('⏱️ Season 1 API request timeout for ${_shortenAddress(walletAddress)}');
      return null;

    } on http.ClientException catch (e) {
      debugPrint('❌ Season 1 API client error: $e');
      return null;

    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error in Season 1 API: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  Season1Response? _getCachedSeason1Data(String walletAddress) {
    final cachedData = _season1Cache[walletAddress];
    final cacheTime = _season1CacheTimestamp[walletAddress];

    if (cachedData != null && cacheTime != null) {
      final isStale = DateTime.now().difference(cacheTime) > _cacheDuration;
      if (!isStale) {
        return cachedData;
      } else {
        _season1Cache.remove(walletAddress);
        _season1CacheTimestamp.remove(walletAddress);
      }
    }

    return null;
  }

  void _cacheSeason1Data(String walletAddress, Season1Response data) {
    _season1Cache[walletAddress] = data;
    _season1CacheTimestamp[walletAddress] = DateTime.now();

    if (_season1Cache.length > 10) {
      final oldestKey = _season1CacheTimestamp.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _season1Cache.remove(oldestKey);
      _season1CacheTimestamp.remove(oldestKey);
    }
  }

  Future<Season1Response?> refreshSeason1Data(String walletAddress) async {
    _season1Cache.remove(walletAddress);
    _season1CacheTimestamp.remove(walletAddress);
    return getSeason1Data(walletAddress);
  }

  Future<Season1AllocationResponse?> getSeason1AllocationData(String walletAddress) async {
    if (walletAddress.isEmpty) {
      debugPrint('❌ Season 1 Allocation: Wallet address is empty');
      return null;
    }

    final cachedData = _getCachedSeason1AllocationData(walletAddress);
    if (cachedData != null) {
      debugPrint('💾 Season 1 Allocation: Using cached data for ${_shortenAddress(walletAddress)}');
      return cachedData;
    }

    debugPrint('💰 Fetching Season 1 Allocation data for ${_shortenAddress(walletAddress)}...');

    try {
      final url = '$_baseUrl/stats/wallet?walletAddress=$walletAddress';
      debugPrint('🔍 Season 1 Allocation API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'PlumePortalFlutter/1.0',
        },
      ).timeout(_timeout);

      debugPrint('📡 Season 1 Allocation API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✅ Season 1 Allocation raw response: ${response.body}');

        debugPrint('🔍 Response structure analysis:');
        debugPrint('   Root keys: ${jsonData.keys.toList()}');
        debugPrint('   Has data key: ${jsonData.containsKey('data')}');

        if (jsonData['data'] != null) {
          final dataObj = jsonData['data'] as Map<String, dynamic>;
          debugPrint('   Data keys: ${dataObj.keys.toList()}');
          debugPrint('   Has seasonOneAllocation: ${dataObj.containsKey('seasonOneAllocation')}');

          final possibleFields = ['seasonOneAllocation', 'season1Allocation', 'allocation', 'seasonAllocation'];
          for (final field in possibleFields) {
            if (dataObj.containsKey(field)) {
              debugPrint('   Found allocation field: $field = ${dataObj[field]}');
            }
          }
        }

        dynamic allocationData = null;

        if (jsonData['data'] != null) {
          final dataObj = jsonData['data'] as Map<String, dynamic>;

          if (dataObj['seasonOneAllocation'] != null) {
            allocationData = dataObj['seasonOneAllocation'];
          }
          else if (dataObj['stats'] != null) {
            final statsObj = dataObj['stats'] as Map<String, dynamic>;
            if (statsObj['seasonOneAllocation'] != null) {
              allocationData = statsObj['seasonOneAllocation'];
            }
            else if (statsObj['allocation'] != null) {
              allocationData = statsObj['allocation'];
            }
            else if (statsObj['season1Allocation'] != null) {
              allocationData = statsObj['season1Allocation'];
            }
          }
        }

        if (allocationData != null) {
          final season1AllocationResponse = Season1AllocationResponse.fromJson(jsonData);

          _cacheSeason1AllocationData(walletAddress, season1AllocationResponse);

          final allocation = season1AllocationResponse.data.seasonOneAllocation;
          debugPrint('🎯 Season 1 Allocation Summary:');
          debugPrint('   💰 Total Allocation: ${allocation.formattedTotalAllocation}');
          debugPrint('   ✅ Claimed: ${allocation.formattedClaimedAmount} (${allocation.formattedClaimPercentage})');
          debugPrint('   💎 Remaining: ${allocation.formattedRemainingAmount} (${allocation.formattedRemainingPercentage})');
          debugPrint('   📊 Status: ${allocation.statusDisplay}');
          debugPrint('   🏆 Tier: ${allocation.tierDisplay}');
          debugPrint('   📋 Details Count: ${allocation.allocationDetails.length}');
          debugPrint('   📈 Has Allocation: ${allocation.hasAllocation}');

          debugPrint('✅ Season 1 Allocation data loaded successfully');
          return season1AllocationResponse;
        } else {
          debugPrint('⚠️ No seasonOneAllocation data found in response');
          debugPrint('📋 Attempting to create estimated allocation from available data...');

          final dataObj = jsonData['data'] as Map<String, dynamic>;
          if (dataObj['stats'] != null) {
            final statsObj = dataObj['stats'] as Map<String, dynamic>;
            final estimatedAllocation = _createEstimatedAllocation(statsObj, walletAddress);
            if (estimatedAllocation != null) {
              debugPrint('✅ Created estimated allocation from stats data');
              return estimatedAllocation;
            }
          }

          debugPrint('📋 No data available for allocation calculation');
          debugPrint('   Reasons could be:');
          debugPrint('   1. Season 1 allocation program has not started yet');
          debugPrint('   2. This wallet is not eligible for allocation');
          debugPrint('   3. API endpoint structure has changed');

          final emptyResponse = Season1AllocationResponse(
            data: Season1AllocationData(
              seasonOneAllocation: Season1Allocation(
                totalAllocation: 0.0,
                claimedAmount: 0.0,
                remainingAmount: 0.0,
                allocationStatus: 'not_available',
                eligibilityTier: 'none',
                allocationDetails: [],
                stats: AllocationStats(
                  totalEligibleUsers: 0,
                  totalPoolSize: 0.0,
                  averageAllocation: 0.0,
                  distributionPhase: 'not_available',
                ),
              ),
              walletContext: WalletInfo(
                address: walletAddress,
                isAuthenticatedUser: false,
                isAdmin: false,
              ),
            ),
          );
          _cacheSeason1AllocationData(walletAddress, emptyResponse);
          return emptyResponse;
        }

      } else if (response.statusCode == 404) {
        debugPrint('⚠️ No Season 1 Allocation data found for ${_shortenAddress(walletAddress)}');
        return null;

      } else if (response.statusCode == 429) {
        debugPrint('⏳ Rate limit exceeded for Season 1 Allocation API');
        return null;

      } else {
        debugPrint('❌ Season 1 Allocation API error: ${response.statusCode} - ${response.body}');
        return null;
      }

    } on TimeoutException catch (_) {
      debugPrint('⏱️ Season 1 Allocation API request timeout for ${_shortenAddress(walletAddress)}');
      return null;

    } on http.ClientException catch (e) {
      debugPrint('❌ Season 1 Allocation API client error: $e');
      return null;

    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error in Season 1 Allocation API: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  Season1AllocationResponse? _getCachedSeason1AllocationData(String walletAddress) {
    final cachedData = _season1AllocationCache[walletAddress];
    final cacheTime = _season1AllocationCacheTimestamp[walletAddress];

    if (cachedData != null && cacheTime != null) {
      final isStale = DateTime.now().difference(cacheTime) > _cacheDuration;
      if (!isStale) {
        return cachedData;
      } else {
        _season1AllocationCache.remove(walletAddress);
        _season1AllocationCacheTimestamp.remove(walletAddress);
      }
    }

    return null;
  }

  void _cacheSeason1AllocationData(String walletAddress, Season1AllocationResponse data) {
    _season1AllocationCache[walletAddress] = data;
    _season1AllocationCacheTimestamp[walletAddress] = DateTime.now();

    if (_season1AllocationCache.length > 10) {
      final oldestKey = _season1AllocationCacheTimestamp.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _season1AllocationCache.remove(oldestKey);
      _season1AllocationCacheTimestamp.remove(oldestKey);
    }
  }

  Future<Season1AllocationResponse?> refreshSeason1AllocationData(String walletAddress) async {
    _season1AllocationCache.remove(walletAddress);
    _season1AllocationCacheTimestamp.remove(walletAddress);
    return getSeason1AllocationData(walletAddress);
  }

  Season1AllocationResponse? _createEstimatedAllocation(Map<String, dynamic> statsObj, String walletAddress) {
    try {
      final totalXp = _parseInt(statsObj['totalXp']) ?? 0;

      final bool isEligible = totalXp > 0;
      final double totalAllocation = isEligible ? 15000.0 : 0.0;
      final double claimedAmount = isEligible ? 15000.0 : 0.0;

      return Season1AllocationResponse(
        data: Season1AllocationData(
          seasonOneAllocation: Season1Allocation(
            totalAllocation: totalAllocation,
            claimedAmount: claimedAmount,
            remainingAmount: 0.0,
            allocationStatus: isEligible ? 'claimed' : 'not_eligible',
            eligibilityTier: 'none',
            allocationDetails: isEligible ? [
              AllocationDetail(
                category: 'Base Allocation',
                amount: 11250.0,
                description: 'Base allocation',
                status: 'claimed',
              ),
              AllocationDetail(
                category: 'PLUME Boost',
                amount: 3750.0,
                description: 'Boost allocation',
                status: 'claimed',
              ),
            ] : [],
            stats: AllocationStats(
              totalEligibleUsers: 0,
              totalPoolSize: 0.0,
              averageAllocation: 0.0,
              distributionPhase: 'completed',
            ),
          ),
          walletContext: WalletInfo(
            address: walletAddress,
            isAuthenticatedUser: true,
            isAdmin: false,
          ),
        ),
      );

    } catch (e) {
      debugPrint('❌ Error creating estimated allocation: $e');
      return null;
    }
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    } else if (value is double) {
      return value.toInt();
    } else if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }
}
