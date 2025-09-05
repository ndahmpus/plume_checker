import 'package:flutter/foundation.dart';

import '../core/services/plume_portal_service.dart';
import '../core/services/portal_stats_service.dart';
import '../services/nucleus_earn_service.dart';
import '../models/plume_portal_models.dart';
import '../models/nucleus_earn_models.dart';
import '../models/portal_stats_models.dart';
import '../services/plume_api_service.dart'; // Import PlumeApiService

class PlumePortalProvider with ChangeNotifier {
  final PlumePortalService _plumePortalService;
  final PortalStatsService _portalStatsService;
  final NucleusEarnService _nucleusEarnService;

  PlumePortalState _state = PlumePortalState();
  PortfolioState _portfolioState = PortfolioState();
  PortalStatsState _portalStatsState = PortalStatsState();
  SkySocietyState _skySocietyState = SkySocietyState();
  DailySpinState _dailySpinState = DailySpinState();
  String? _currentWalletAddress;

  PlumePortalProvider(
    this._plumePortalService,
    this._portalStatsService,
    this._nucleusEarnService,
  );

  PlumePortalState get state => _state;
  PortfolioState get portfolioState => _portfolioState;
  String? get currentWalletAddress => _currentWalletAddress;
  bool get isLoading => _state.isLoading || _portfolioState.isLoading || _portalStatsState.isLoading || _skySocietyState.isLoading || _dailySpinState.isLoading;
  bool get hasData => _state.hasData;
  bool get hasError => _state.hasError;
  String? get errorMessage => _state.errorMessage;
  PlumePortalResponse? get data => _state.data;

  UserPortfolioResponse? get portfolioData => _portfolioState.portfolio;
  bool get isPortfolioLoaded => _portfolioState.hasData;
  bool get isPortfolioLoading => _portfolioState.isLoading;
  bool get hasPortfolioError => _portfolioState.hasError;
  String? get portfolioErrorMessage => _portfolioState.errorMessage;
  bool get hasPortfolioData => _portfolioState.hasData && _portfolioState.portfolio != null && _portfolioState.portfolio!.hasData;

  String get portfolioSummary {
    if (!hasPortfolioData) return 'No portfolio data available';

    final portfolio = _portfolioState.portfolio!;
    final tokens = portfolio.totalTokenCount;
    final totalValue = portfolio.totalValue;

    if (tokens == 0) {
      return 'No tokens found';
    } else if (tokens == 1) {
      return '1 token (\$${totalValue.toStringAsFixed(2)})';
    } else {
      return '$tokens tokens (\$${totalValue.toStringAsFixed(2)})';
    }
  }

  PortalStatsState get portalStatsState => _portalStatsState;
  PortalStatsResponse? get portalStatsData => _portalStatsState.stats;
  bool get hasPortalStatsData => _portalStatsState.hasData;
  bool get isPortalStatsLoading => _portalStatsState.isLoading;
  bool get hasPortalStatsError => _portalStatsState.hasError;
  String? get portalStatsErrorMessage => _portalStatsState.errorMessage;
  WalletStats? get walletStats => _portalStatsState.stats?.data.stats;

  SkySocietyState get skySocietyState => _skySocietyState;
  SkySocietyResponse? get skySocietyData => _skySocietyState.data;
  bool get hasSkySocietyData => _skySocietyState.hasData;
  bool get isSkySocietyLoading => _skySocietyState.isLoading;
  bool get hasSkySocietyError => _skySocietyState.hasError;
  String? get skySocietyErrorMessage => _skySocietyState.errorMessage;

  DailySpinState get dailySpinState => _dailySpinState;
  DailySpinResponse? get dailySpinData => _dailySpinState.data;
  bool get hasDailySpinData => _dailySpinState.hasData;
  bool get isDailySpinLoading => _dailySpinState.isLoading;
  bool get hasDailySpinError => _dailySpinState.hasError;
  String? get dailySpinErrorMessage => _dailySpinState.errorMessage;

  PpScores? get ppScores => _state.data?.data.ppScores;
  XpData? get activeXp => ppScores?.activeXp;
  XpData? get prevXp => ppScores?.prevXp;
  WalletContext? get walletContext => _state.data?.data.walletContext;
  int get totalXp => activeXp?.totalXp ?? 0;
  int get xpDelta => ppScores?.xpDelta ?? 0;
  double get xpGrowthPercentage => ppScores?.xpGrowthPercentage ?? 0.0;

  Future<void> loadPpTotals(String walletAddress, {bool forceRefresh = false}) async {
    if (!_plumePortalService.isInitialized) {
      _setState(_state.copyWith(
        loadingState: PlumePortalLoadingState.error,
        errorMessage: 'PlumePortalService belum diinisialisasi',
      ));
      return;
    }

    if (!forceRefresh && 
        _currentWalletAddress == walletAddress && 
        _state.hasData) {
      return;
    }

    _currentWalletAddress = walletAddress;
    _setState(_state.copyWith(
      loadingState: PlumePortalLoadingState.loading,
      errorMessage: null,
    ));

    try {
      final response = await _plumePortalService.getPpTotals(
        walletAddress,
        forceRefresh: forceRefresh,
      );

      if (response != null) {
        _setState(_state.copyWith(
          loadingState: PlumePortalLoadingState.success,
          data: response,
          errorMessage: null,
        ));
      } else {
        _setState(_state.copyWith(
          loadingState: PlumePortalLoadingState.error,
          errorMessage: 'Tidak ada data ditemukan untuk wallet ini',
        ));
      }
    } on PlumePortalException catch (e) {
      String userFriendlyMessage;
      switch (e.statusCode) {
        case 404:
          userFriendlyMessage = 'Wallet address tidak ditemukan atau belum memiliki aktivitas';
          break;
        case 429:
          userFriendlyMessage = 'Terlalu banyak request. Mohon tunggu beberapa saat.';
          break;
        default:
          userFriendlyMessage = e.message;
      }

      _setState(_state.copyWith(
        loadingState: PlumePortalLoadingState.error,
        errorMessage: userFriendlyMessage,
      ));
    } catch (e) {
      _setState(_state.copyWith(
        loadingState: PlumePortalLoadingState.error,
        errorMessage: 'Terjadi kesalahan: ${e.toString()}',
      ));
    }
  }

  Future<void> searchWallet(String walletAddress) async {
    if (walletAddress.isEmpty) {
      _setState(_state.copyWith(
        loadingState: PlumePortalLoadingState.error,
        errorMessage: 'Wallet address tidak boleh kosong',
      ));
      return;
    }

    if (walletAddress.length != 42 || !walletAddress.startsWith('0x')) {
      _setState(_state.copyWith(
        loadingState: PlumePortalLoadingState.error,
        errorMessage: 'Format wallet address tidak valid. Harus berupa alamat Ethereum yang valid (0x...)',
      ));
      return;
    }

    clearAll();

    await loadCompleteWalletData(walletAddress, forceRefresh: true);
  }

  Future<void> loadCompleteWalletData(String walletAddress, {bool forceRefresh = false}) async {
    _currentWalletAddress = walletAddress;

    await Future.wait([
      loadPpTotals(walletAddress, forceRefresh: forceRefresh),
      loadPortfolio(walletAddress, forceRefresh: forceRefresh),
      loadPortalStats(walletAddress, forceRefresh: forceRefresh),
      loadSkySocietyData(walletAddress, forceRefresh: forceRefresh),
      loadDailySpinData(walletAddress, forceRefresh: forceRefresh),
    ]);
  }

  Future<void> refreshAllData() async {
    if (_currentWalletAddress != null) {
      await loadCompleteWalletData(_currentWalletAddress!, forceRefresh: true);
    }
  }

  void clearAll() {
    _currentWalletAddress = null;
    _setState(PlumePortalState());
    _setPortfolioState(PortfolioState());
    _setPortalStatsState(PortalStatsState());
    _setSkySocietyState(SkySocietyState());
    _setDailySpinState(DailySpinState());
    _plumePortalService.clearCache();
    _portalStatsService.clearCache();
    _nucleusEarnService.clearCache();
  }

  Future<void> loadPortfolio(String walletAddress, {bool forceRefresh = false}) async {
    if (walletAddress.isEmpty || walletAddress.length != 42 || !walletAddress.startsWith('0x')) {
      _setPortfolioState(_portfolioState.copyWith(loadingState: PortfolioLoadingState.error, errorMessage: 'Invalid wallet address format'));
      return;
    }

    if (!forceRefresh && _portfolioState.currentWalletAddress == walletAddress && _portfolioState.hasData) {
      return;
    }

    _setPortfolioState(_portfolioState.copyWith(loadingState: PortfolioLoadingState.loading, errorMessage: null, currentWalletAddress: walletAddress));

    try {
      if (!_nucleusEarnService.isInitialized) {
        print('🔄 NucleusEarnService not initialized, initializing now...');
        await _nucleusEarnService.initialize();
      }

      print('🔍 Fetching portfolio for wallet: $walletAddress');
      final portfolio = await _nucleusEarnService.getUserPortfolio(walletAddress, forceRefresh: forceRefresh);

      if (portfolio != null && portfolio.hasData) {
        print('✅ Portfolio loaded successfully with ${portfolio.totalTokenCount} tokens');
        _setPortfolioState(_portfolioState.copyWith(loadingState: PortfolioLoadingState.success, portfolio: portfolio, errorMessage: null));
      } else {
        print('📭 No portfolio data found for wallet: $walletAddress');
        _setPortfolioState(_portfolioState.copyWith(loadingState: PortfolioLoadingState.empty, errorMessage: null));
      }
    } on NucleusEarnException catch (e) {
      print('❌ NucleusEarnException: ${e.message}');
      String userMessage = e.message;
      if (e.statusCode == 404) {
        userMessage = 'Portfolio tidak ditemukan untuk wallet ini';
      } else if (e.statusCode == 429) {
        userMessage = 'Terlalu banyak request. Mohon tunggu sebentar.';
      } else if (e.statusCode == null) {
        userMessage = 'Service tidak tersedia. Silakan coba lagi.';
      }
      _setPortfolioState(_portfolioState.copyWith(loadingState: PortfolioLoadingState.error, errorMessage: userMessage));
    } catch (e) {
      print('❌ Portfolio loading error: $e');
      String userMessage = 'Gagal memuat data portfolio';
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        userMessage = 'Koneksi bermasalah. Periksa internet Anda.';
      } else if (e.toString().contains('FormatException')) {
        userMessage = 'Format data tidak valid dari server';
      }
      _setPortfolioState(_portfolioState.copyWith(loadingState: PortfolioLoadingState.error, errorMessage: userMessage));
    }
  }

  Future<void> loadPortalStats(String walletAddress, {bool forceRefresh = false}) async {
    if (!_portalStatsService.isInitialized) {
      _setPortalStatsState(_portalStatsState.copyWith(loadingState: PortalStatsLoadingState.error, errorMessage: 'Portal Stats Service belum diinisialisasi'));
      return;
    }
    if (!forceRefresh && _portalStatsState.currentWalletAddress == walletAddress && _portalStatsState.hasData) {
      return;
    }
    _setPortalStatsState(_portalStatsState.copyWith(loadingState: PortalStatsLoadingState.loading, errorMessage: null, currentWalletAddress: walletAddress));
    try {
      final stats = await _portalStatsService.getWalletStats(walletAddress, forceRefresh: forceRefresh);
      if (stats != null) {
        _setPortalStatsState(_portalStatsState.copyWith(loadingState: PortalStatsLoadingState.success, stats: stats, errorMessage: null, lastUpdated: DateTime.now()));
      } else {
        _setPortalStatsState(_portalStatsState.copyWith(loadingState: PortalStatsLoadingState.empty, errorMessage: 'Tidak ada data stats ditemukan untuk wallet ini'));
      }
    } catch (e) {
      _setPortalStatsState(_portalStatsState.copyWith(loadingState: PortalStatsLoadingState.error, errorMessage: 'Terjadi kesalahan: ${e.toString()}'));
    }
  }

  Future<void> loadSkySocietyData(String walletAddress, {bool forceRefresh = false}) async {
    if (!forceRefresh && _skySocietyState.currentWalletAddress == walletAddress && _skySocietyState.hasData) {
      return;
    }
    _setSkySocietyState(_skySocietyState.copyWith(loadingState: SkySocietyLoadingState.loading, errorMessage: null, currentWalletAddress: walletAddress));
    try {
      final service = PlumeApiService();
      final response = await service.getSkyScietyData(walletAddress);
      if (response != null && response.data.skySocietyTier != null) {
        _setSkySocietyState(_skySocietyState.copyWith(loadingState: SkySocietyLoadingState.success, data: response, lastUpdated: DateTime.now()));
      } else {
        _setSkySocietyState(_skySocietyState.copyWith(loadingState: SkySocietyLoadingState.empty, errorMessage: 'Tidak ada data Sky Society ditemukan'));
      }
    } catch (e) {
      _setSkySocietyState(_skySocietyState.copyWith(loadingState: SkySocietyLoadingState.error, errorMessage: 'Gagal memuat data Sky Society: ${e.toString()}'));
    }
  }

  Future<void> loadDailySpinData(String walletAddress, {bool forceRefresh = false}) async {
    if (!forceRefresh && _dailySpinState.currentWalletAddress == walletAddress && _dailySpinState.hasData) {
      return;
    }
    _setDailySpinState(_dailySpinState.copyWith(loadingState: DailySpinLoadingState.loading, errorMessage: null, currentWalletAddress: walletAddress));
    try {
      final service = PlumeApiService();
      final response = await service.getDailySpinData(walletAddress);
      if (response != null) {
        _setDailySpinState(_dailySpinState.copyWith(loadingState: DailySpinLoadingState.success, data: response, lastUpdated: DateTime.now()));
      } else {
        _setDailySpinState(_dailySpinState.copyWith(loadingState: DailySpinLoadingState.empty, errorMessage: 'Tidak ada data Daily Spin ditemukan'));
      }
    } catch (e) {
      _setDailySpinState(_dailySpinState.copyWith(loadingState: DailySpinLoadingState.error, errorMessage: 'Gagal memuat data Daily Spin: ${e.toString()}'));
    }
  }

  void _setState(PlumePortalState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setPortfolioState(PortfolioState newState) {
    _portfolioState = newState;
    notifyListeners();
  }

  void _setPortalStatsState(PortalStatsState newState) {
    _portalStatsState = newState;
    notifyListeners();
  }

  void _setSkySocietyState(SkySocietyState newState) {
    _skySocietyState = newState;
    notifyListeners();
  }

  void _setDailySpinState(DailySpinState newState) {
    _dailySpinState = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    clearAll();
    super.dispose();
  }
}

class SkySocietyState {
  final SkySocietyLoadingState loadingState;
  final SkySocietyResponse? data;
  final String? errorMessage;
  final String? currentWalletAddress;
  final DateTime? lastUpdated;

  SkySocietyState({
    this.loadingState = SkySocietyLoadingState.initial,
    this.data,
    this.errorMessage,
    this.currentWalletAddress,
    this.lastUpdated,
  });

  bool get isLoading => loadingState == SkySocietyLoadingState.loading;
  bool get hasData => loadingState == SkySocietyLoadingState.success && data != null;
  bool get hasError => loadingState == SkySocietyLoadingState.error;

  SkySocietyState copyWith({
    SkySocietyLoadingState? loadingState,
    SkySocietyResponse? data,
    String? errorMessage,
    String? currentWalletAddress,
    DateTime? lastUpdated,
  }) {
    return SkySocietyState(
      loadingState: loadingState ?? this.loadingState,
      data: data ?? this.data,
      errorMessage: errorMessage,
      currentWalletAddress: currentWalletAddress ?? this.currentWalletAddress,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
enum SkySocietyLoadingState { initial, loading, success, error, empty }

class DailySpinState {
  final DailySpinLoadingState loadingState;
  final DailySpinResponse? data;
  final String? errorMessage;
  final String? currentWalletAddress;
  final DateTime? lastUpdated;

  DailySpinState({
    this.loadingState = DailySpinLoadingState.initial,
    this.data,
    this.errorMessage,
    this.currentWalletAddress,
    this.lastUpdated,
  });

  bool get isLoading => loadingState == DailySpinLoadingState.loading;
  bool get hasData => loadingState == DailySpinLoadingState.success && data != null;
  bool get hasError => loadingState == DailySpinLoadingState.error;

  DailySpinState copyWith({
    DailySpinLoadingState? loadingState,
    DailySpinResponse? data,
    String? errorMessage,
    String? currentWalletAddress,
    DateTime? lastUpdated,
  }) {
    return DailySpinState(
      loadingState: loadingState ?? this.loadingState,
      data: data ?? this.data,
      errorMessage: errorMessage,
      currentWalletAddress: currentWalletAddress ?? this.currentWalletAddress,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
enum DailySpinLoadingState { initial, loading, success, error, empty }

enum GrowthStatus {
  positive,
  negative,
  neutral,
}

extension PlumePortalProviderExtensions on PlumePortalProvider {
  List<String> get topActivities => ppScores?.top3PointsDeltasStrings ?? [];

  bool get isAuthenticated => walletContext?.isAuthenticatedUser ?? false;

  String get formattedWalletAddress => walletContext?.shortAddress ?? '';

  String get lastUpdateTime => activeXp?.formattedDate ?? '';

  Map<String, dynamic> get referralInfo => {
    'hasReferralBonus': (activeXp?.referralBonusXp ?? 0) > 0,
    'referralXp': activeXp?.referralBonusXp ?? 0,
    'selfXp': activeXp?.userSelfXp ?? 0,
    'referralPercentage': totalXp > 0 ? ((activeXp?.referralBonusXp ?? 0) / totalXp * 100) : 0.0,
  };

  String get activityLevel {
    if (hasPortalStatsData) {
      return walletStats!.activityLevel;
    }
    final score = totalXp;
    if (score >= 10000) return 'Very Active';
    if (score >= 5000) return 'Active';
    if (score >= 1000) return 'Moderate';
    if (score > 0) return 'Beginner';
    return 'No Activity';
  }

  String formatXp(int xp) {
    return xp.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String formatGrowthPercentage(double percentage) {
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(1)}%';
  }

  GrowthStatus getGrowthStatus() {
    if (xpDelta > 0) return GrowthStatus.positive;
    if (xpDelta < 0) return GrowthStatus.negative;
    return GrowthStatus.neutral;
  }
}
