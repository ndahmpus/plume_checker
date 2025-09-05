import 'package:flutter/foundation.dart';

class UserPortfolioResponse {
  final String walletAddress;
  final List<PortfolioItem> portfolioItems;
  final DateTime timestamp;
  final bool hasData;

  UserPortfolioResponse({
    required this.walletAddress,
    required this.portfolioItems,
    required this.timestamp,
    required this.hasData,
  });

  factory UserPortfolioResponse.fromJson(Map<String, dynamic> json, String walletAddress) {
    return UserPortfolioResponse(
      walletAddress: walletAddress,
      portfolioItems: [PortfolioItem.fromJson(json)],
      timestamp: DateTime.now(),
      hasData: true,
    );
  }

  factory UserPortfolioResponse.fromJsonList(List<dynamic> jsonList, String walletAddress) {
    final items = jsonList
        .map((item) => PortfolioItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return UserPortfolioResponse(
      walletAddress: walletAddress,
      portfolioItems: items,
      timestamp: DateTime.now(),
      hasData: items.isNotEmpty,
    );
  }

  factory UserPortfolioResponse.empty(String walletAddress) {
    return UserPortfolioResponse(
      walletAddress: walletAddress,
      portfolioItems: [],
      timestamp: DateTime.now(),
      hasData: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletAddress': walletAddress,
      'portfolioItems': portfolioItems.map((item) => item.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'hasData': hasData,
    };
  }

  double get totalValue {
    return portfolioItems.fold(0.0, (sum, item) => sum + item.totalValue);
  }

  double get totalValueUsd => totalValue;

  int get totalTokenCount {
    return portfolioItems.length;
  }

  String get formattedTotalValue {
    return '\$${totalValue.toStringAsFixed(2)}';
  }

  List<PortfolioItem> get topAssets {
    final sortedItems = List<PortfolioItem>.from(portfolioItems);
    sortedItems.sort((a, b) => b.totalValue.compareTo(a.totalValue));
    return sortedItems.take(5).toList();
  }

  double get diversityScore {
    if (portfolioItems.isEmpty) return 0.0;

    final totalValue = this.totalValue;
    if (totalValue == 0) return 0.0;

    double herfindahl = 0.0;
    for (final item in portfolioItems) {
      final weight = item.totalValue / totalValue;
      herfindahl += weight * weight;
    }

    return (1 - herfindahl) * 100;
  }

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else {
      return '${diff.inDays} hari lalu';
    }
  }

  String get summary {
    if (!hasData) return 'Tidak ada data portfolio';

    return '$totalTokenCount token, Total: $formattedTotalValue';
  }

  bool get isEmpty {
    return !hasData || portfolioItems.isEmpty;
  }
}

class PortfolioItem {
  final String tokenName;
  final String tokenSymbol;
  final String tokenAddress;
  final double balance;
  final double price;
  final double totalValue;
  final String? logoUrl;
  final int decimals;
  final String network;

  PortfolioItem({
    required this.tokenName,
    required this.tokenSymbol,
    required this.tokenAddress,
    required this.balance,
    required this.price,
    required this.totalValue,
    this.logoUrl,
    this.decimals = 18,
    this.network = 'plume',
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {

    double balance;
    if (json.containsKey('balanceScaledDown')) {
      balance = _parseDouble(json['balanceScaledDown'] ?? 0);
    } else {
      balance = _parseDouble(json['balance'] ?? json['amount'] ?? 0);
    }

    double price = 0.0;
    double totalValue;

    if (json.containsKey('balanceInUsd')) {
      totalValue = _parseDouble(json['balanceInUsd'] ?? 0);
      if (balance > 0) {
        price = totalValue / balance;
      }
    } else {
      price = _parseDouble(json['price'] ?? json['token_price'] ?? 0);
      totalValue = _parseDouble(json['total_value'] ?? (balance * price));
    }

    String tokenAddress = '';
    if (json.containsKey('inputToken')) {
      tokenAddress = json['inputToken'] ?? '';
    } else {
      tokenAddress = json['token_address'] ?? json['address'] ?? '';
    }

    String tokenName = 'Unknown Token';
    String tokenSymbol = 'UNKNOWN';

    if (tokenAddress.isNotEmpty) {
      final tokenInfo = _getTokenInfoFromAddress(tokenAddress);
      tokenName = tokenInfo['name']!;
      tokenSymbol = tokenInfo['symbol']!;
    }

    tokenName = json['token_name'] ?? json['name'] ?? tokenName;
    tokenSymbol = json['token_symbol'] ?? json['symbol'] ?? tokenSymbol;

    debugPrint('🔍 PortfolioItem parsed: $tokenSymbol ($tokenName) | Address: ${tokenAddress.substring(0, 8)}...${tokenAddress.substring(tokenAddress.length - 4)} | Balance: ${balance.toStringAsFixed(4)} | Price: \$${price.toStringAsFixed(4)} | Total: \$${totalValue.toStringAsFixed(2)}');

    return PortfolioItem(
      tokenName: tokenName,
      tokenSymbol: tokenSymbol,
      tokenAddress: tokenAddress,
      balance: balance,
      price: price,
      totalValue: totalValue,
      logoUrl: json['logo_url'] ?? json['logo'] ?? json['image'],
      decimals: _parseInt(json['decimals'] ?? 18),
      network: json['network'] ?? json['chain'] ?? 'plume',
    );
  }

  static Future<PortfolioItem> fromJsonWithTokenInfo(
    Map<String, dynamic> json, {
    Function(String)? tokenInfoProvider,
  }) async {
    final basicItem = PortfolioItem.fromJson(json);

    if (tokenInfoProvider != null && basicItem.tokenAddress.isNotEmpty) {
      try {
        return basicItem;
      } catch (e) {
        return basicItem;
      }
    }

    return basicItem;
  }

  static Map<String, String> _getTokenInfoFromAddress(String address) {
    final Map<String, Map<String, String>> addressToTokenInfo = {
      '0x593ccca4c4bf58b7526a4c164ceef4003c6388db': {
        'name': 'Wrapped ETH',
        'symbol': 'WETH',
        'type': 'wrapped',
      },
      '0x11113ff3a60c2450f4b22515cb760417259ee94b': {
        'name': 'USD Coin',
        'symbol': 'USDC',
        'type': 'stablecoin',
      },
      '0xea237441c92cae6fc17caaf9a7acb3f953be4bd1': {
        'name': 'Plume Token',
        'symbol': 'PLUME',
        'type': 'native',
      },
    };

    final normalizedAddress = address.toLowerCase();

    if (addressToTokenInfo.containsKey(normalizedAddress)) {
      return addressToTokenInfo[normalizedAddress]!;
    }

    return {
      'name': 'Unknown Token',
      'symbol': _generateSymbolFromAddress(address),
      'type': 'unknown',
    };
  }

  static String _generateSymbolFromAddress(String address) {
    if (address.length < 8) return 'UNK';

    final suffix = address.substring(address.length - 4).toUpperCase();
    return 'T$suffix'; // e.g., T38DB for address ending in 38db
  }

  Map<String, dynamic> toJson() {
    return {
      'token_name': tokenName,
      'token_symbol': tokenSymbol,
      'token_address': tokenAddress,
      'balance': balance,
      'price': price,
      'total_value': totalValue,
      'logo_url': logoUrl,
      'decimals': decimals,
      'network': network,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  String get formattedBalance {
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(2)}M';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(2)}K';
    } else if (balance >= 1) {
      return balance.toStringAsFixed(4);
    } else {
      return balance.toStringAsFixed(8);
    }
  }

  String get formattedPrice {
    if (price >= 1) {
      return '\$${price.toStringAsFixed(2)}';
    } else {
      return '\$${price.toStringAsFixed(8)}';
    }
  }

  String get formattedTotalValue {
    return '\$${totalValue.toStringAsFixed(2)}';
  }

  double getWeightPercentage(double totalPortfolioValue) {
    if (totalPortfolioValue == 0) return 0.0;
    return (totalValue / totalPortfolioValue) * 100;
  }

  String getFormattedWeight(double totalPortfolioValue) {
    return '${getWeightPercentage(totalPortfolioValue).toStringAsFixed(1)}%';
  }

  bool get isStablecoin {
    final stablecoins = ['USDT', 'USDC', 'DAI', 'BUSD', 'UST', 'FRAX'];
    return stablecoins.contains(tokenSymbol.toUpperCase());
  }

  int get tokenColor {
    switch (tokenSymbol.toUpperCase()) {
      case 'PLUME':
        return 0xFF6366F1;
      case 'ETH':
        return 0xFF627EEA;
      case 'BTC':
        return 0xFFF7931A;
      case 'USDT':
        return 0xFF26A17B;
      case 'USDC':
        return 0xFF2775CA;
      default:
        return 0xFF8B5CF6;
    }
  }

  String get shortAddress {
    if (tokenAddress.length <= 10) return tokenAddress;
    return '${tokenAddress.substring(0, 6)}...${tokenAddress.substring(tokenAddress.length - 4)}';
  }
}

class PortfolioStats {
  final double totalValue;
  final double dailyChange;
  final double dailyChangePercentage;
  final int totalTokens;
  final double diversityScore;
  final Map<String, double> tokenWeights;
  final DateTime lastUpdated;

  PortfolioStats({
    required this.totalValue,
    required this.dailyChange,
    required this.dailyChangePercentage,
    required this.totalTokens,
    required this.diversityScore,
    required this.tokenWeights,
    required this.lastUpdated,
  });

  factory PortfolioStats.fromPortfolio(UserPortfolioResponse portfolio) {
    final tokenWeights = <String, double>{};
    final totalValue = portfolio.totalValue;

    for (final item in portfolio.portfolioItems) {
      tokenWeights[item.tokenSymbol] = item.getWeightPercentage(totalValue);
    }

    return PortfolioStats(
      totalValue: totalValue,
      dailyChange: 0.0,
      dailyChangePercentage: 0.0,
      totalTokens: portfolio.totalTokenCount,
      diversityScore: portfolio.diversityScore,
      tokenWeights: tokenWeights,
      lastUpdated: portfolio.timestamp,
    );
  }

  String get formattedTotalValue {
    return '\$${totalValue.toStringAsFixed(2)}';
  }

  String get formattedDailyChange {
    final sign = dailyChange >= 0 ? '+' : '';
    return '$sign\$${dailyChange.toStringAsFixed(2)}';
  }

  String get formattedDailyChangePercentage {
    final sign = dailyChangePercentage >= 0 ? '+' : '';
    return '$sign${dailyChangePercentage.toStringAsFixed(2)}%';
  }

  bool get isDailyChangePositive => dailyChange >= 0;

  String get diversityLevel {
    if (diversityScore >= 80) return 'Very Diverse';
    if (diversityScore >= 60) return 'Well Diversified';
    if (diversityScore >= 40) return 'Moderately Diverse';
    if (diversityScore >= 20) return 'Low Diversity';
    return 'Concentrated';
  }

  String get topToken {
    if (tokenWeights.isEmpty) return 'N/A';

    final sortedWeights = tokenWeights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedWeights.first.key;
  }
}

enum PortfolioLoadingState {
  initial,
  loading,
  success,
  error,
  empty,
}

class PortfolioState {
  final PortfolioLoadingState loadingState;
  final UserPortfolioResponse? portfolio;
  final String? errorMessage;
  final String? currentWalletAddress;

  PortfolioState({
    this.loadingState = PortfolioLoadingState.initial,
    this.portfolio,
    this.errorMessage,
    this.currentWalletAddress,
  });

  PortfolioState copyWith({
    PortfolioLoadingState? loadingState,
    UserPortfolioResponse? portfolio,
    String? errorMessage,
    String? currentWalletAddress,
  }) {
    return PortfolioState(
      loadingState: loadingState ?? this.loadingState,
      portfolio: portfolio ?? this.portfolio,
      errorMessage: errorMessage,
      currentWalletAddress: currentWalletAddress ?? this.currentWalletAddress,
    );
  }

  bool get isLoading => loadingState == PortfolioLoadingState.loading;
  bool get hasData => portfolio != null && portfolio!.hasData && loadingState == PortfolioLoadingState.success;
  bool get hasError => loadingState == PortfolioLoadingState.error;
  bool get isEmpty => loadingState == PortfolioLoadingState.empty || (portfolio != null && !portfolio!.hasData);

  PortfolioStats? get stats {
    if (!hasData) return null;
    return PortfolioStats.fromPortfolio(portfolio!);
  }
}

extension UserPortfolioResponseExtensions on UserPortfolioResponse {
  Map<String, List<PortfolioItem>> get tokensByCategory {
    final categories = <String, List<PortfolioItem>>{
      'Stablecoins': [],
      'Major Tokens': [],
      'Others': [],
    };

    for (final item in portfolioItems) {
      if (item.isStablecoin) {
        categories['Stablecoins']!.add(item);
      } else if (['ETH', 'BTC', 'PLUME'].contains(item.tokenSymbol.toUpperCase())) {
        categories['Major Tokens']!.add(item);
      } else {
        categories['Others']!.add(item);
      }
    }

    categories.removeWhere((key, value) => value.isEmpty);

    return categories;
  }

  PortfolioItem? get largestHolding {
    if (portfolioItems.isEmpty) return null;

    return portfolioItems.reduce((a, b) => a.totalValue > b.totalValue ? a : b);
  }

  PortfolioItem? get smallestHolding {
    if (portfolioItems.isEmpty) return null;

    return portfolioItems.reduce((a, b) => a.totalValue < b.totalValue ? a : b);
  }

  List<PortfolioItem> searchTokens(String query) {
    if (query.isEmpty) return portfolioItems;

    final lowercaseQuery = query.toLowerCase();
    return portfolioItems.where((item) =>
      item.tokenName.toLowerCase().contains(lowercaseQuery) ||
      item.tokenSymbol.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
}
