import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/plume_api_service.dart';
import '../models/plume_portal_models.dart';
import '../utils/app_fonts.dart';

import '../providers/plume_portal_provider.dart';
import '../core/services/plume_portal_service.dart';
import '../core/services/portal_stats_service.dart';
import '../services/nucleus_earn_service.dart';
import '../models/nucleus_earn_models.dart';
import 'package:provider/provider.dart';
import '../widgets/enso_wallet_balances_widget.dart';
import '../widgets/plume_badges_widget.dart';
import '../widgets/portfolio_widgets.dart';
import '../widgets/season1_widget.dart';
import '../services/wallet_history_service.dart';
import '../widgets/optimized_loading_screen.dart';
import '../services/cache_service.dart';

enum BattleGroupRankChange {
  none,
  up,
  down,
  stable,
}

class PlumePortalScreen extends StatefulWidget {
  final String walletAddress;

  const PlumePortalScreen({
    super.key,
    required this.walletAddress,
  });

  @override
  State<PlumePortalScreen> createState() => _PlumePortalScreenState();
}

class _PlumePortalScreenState extends State<PlumePortalScreen> {
  PlumeWalletData? _walletData;
  PortalWalletStatsResponse? _comprehensiveStats;
  bool _isLoading = false;
  bool _isRefreshing = false;
  DateTime? _lastRefresh;
  bool _isDataLoadedFromCache = false;

  PpScores? _ppScores;
  XpData? _activeXp;
  XpData? _prevXp;
  bool _isLoadingPpScores = false;

  SkySocietyResponse? _skySocietyData;
  bool _isLoadingSkySociety = false;

  WalletBalanceResponse? _walletBalanceData;
  bool _isLoadingWalletBalance = false;

  int? _blockchainTxCount;
  int? _totalBadgeCount;
  bool _isLoadingActivityData = false;

  DailySpinResponse? _dailySpinData;
  bool _isLoadingDailySpinData = false;

  List<WalletHistoryItem> _walletHistory = [];
  bool _isLoadingHistory = false;

  bool _showAllTokens = false;

  String? _previousBattleGroup;
  String? _currentBattleGroup;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
    _loadWalletHistory();
    _saveToHistory(widget.walletAddress);
  }

  Future<void> _loadWalletHistory() async {
    if (_isLoadingHistory) return;

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final history = await WalletHistoryService.instance.getHistory();
      if (mounted) {
        setState(() {
          _walletHistory = history;
        });
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  Future<void> _saveToHistory(String address) async {
    try {
      await WalletHistoryService.instance.addToHistory(address);
      await _loadWalletHistory();
    } catch (e) {
    }
  }

  @Deprecated('This method is not currently used in the UI')
  Future<void> _clearAllHistory() async {
    try {
      await WalletHistoryService.instance.clearHistory();
      await _loadWalletHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Wallet history cleared'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
    }
  }

  @Deprecated('This method is not currently used in the UI')
  Future<void> _removeFromHistory(String address) async {
    try {
      await WalletHistoryService.instance.removeFromHistory(address);
      await _loadWalletHistory();
    } catch (e) {
    }
  }

  Future<void> _loadWalletData() async {
    if (_isLoading) return;

    await CacheService.instance.initialize();

    final cacheService = CacheService.instance;
    final cacheStatus = cacheService.getCacheStatus(widget.walletAddress);

    if (cacheStatus['walletData'] == true && 
        cacheStatus['ppScores'] == true &&
        cacheStatus['skySociety'] == true &&
        cacheStatus['walletBalance'] == true) {
      debugPrint('📦 All data available in cache - loading immediately');
      await _loadDataFromCache();
      return;
    }

    await _loadWalletDataFromAPI();
  }

  Future<void> _loadPpTotalsData({bool forceRefresh = false}) async {
    if (_isLoadingPpScores) return;

    setState(() {
      _isLoadingPpScores = true;
    });

    try {
      final service = PlumeApiService();
      final ppScoresResponse = await service.fetchPpTotals(widget.walletAddress, forceRefresh: forceRefresh);

      if (mounted && ppScoresResponse != null) {
        setState(() {
          _ppScores = ppScoresResponse;
          _activeXp = ppScoresResponse.activeXp;
          _prevXp = ppScoresResponse.prevXp;
        });
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPpScores = false;
        });
      }
    }
  }

  Future<void> _loadWalletBalanceData({bool forceRefresh = false}) async {
    if (_isLoadingWalletBalance) return;

    setState(() {
      _isLoadingWalletBalance = true;
    });

    try {
      final service = PlumeApiService();
      final walletBalanceResponse = await service.getWalletBalance(widget.walletAddress, forceRefresh: forceRefresh);

      if (mounted) {
        if (walletBalanceResponse != null) {
          setState(() {
            _walletBalanceData = walletBalanceResponse;
          });
        } else {
          setState(() {
            _walletBalanceData = null;
          });
        }
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _walletBalanceData = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWalletBalance = false;
        });
      }
    }
  }

  Future<void> _loadSkySocietyData({bool forceRefresh = false}) async {
    if (_isLoadingSkySociety) return;

    setState(() {
      _isLoadingSkySociety = true;
    });

    try {
      final service = PlumeApiService();
      final skySocietyResponse = await service.getSkyScietyData(widget.walletAddress, forceRefresh: forceRefresh);

      if (mounted) {
        if (skySocietyResponse != null && skySocietyResponse.data.skySocietyTier != null) {
          setState(() {
            _skySocietyData = skySocietyResponse;
          });
        } else {
          setState(() {
            _skySocietyData = null;
          });
        }
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _skySocietyData = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSkySociety = false;
        });
      }
    }
  }

  Future<void> _loadDailySpinData({bool forceRefresh = false}) async {
    if (_isLoadingDailySpinData) return;

    setState(() {
      _isLoadingDailySpinData = true;
    });

    try {
      final service = PlumeApiService();
      final dailySpinResponse = await service.getDailySpinData(widget.walletAddress, forceRefresh: forceRefresh);

      if (mounted) {
        if (dailySpinResponse != null) {
          setState(() {
            _dailySpinData = dailySpinResponse;
          });
        } else {
          setState(() {
            _dailySpinData = null;
          });
        }
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _dailySpinData = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDailySpinData = false;
        });
      }
    }
  }

  Future<void> _loadActivityData() async {
    if (_isLoadingActivityData) return;

    setState(() {
      _isLoadingActivityData = true;
    });

    try {
      int actualTxCount = 0;
      try {
        actualTxCount = await PlumeApiService().getTransactionCount(widget.walletAddress);
      } catch (e) {
        actualTxCount = 0;
      }

      int actualBadgeCount = 0;
      try {
        actualBadgeCount = await PlumeApiService().getBadgeCount(widget.walletAddress);
      } catch (e) {
        if (_comprehensiveStats != null) {
          final stats = _comprehensiveStats!.data.stats;
          int realSpinStreak = stats.dailySpinStreak;
          if (_dailySpinData != null) {
            realSpinStreak = PortalWalletStats.calculateRealCurrentStreak(_dailySpinData!.data.spins);
          }

          actualBadgeCount = (stats.completedQuests ?? 0).clamp(0, 10) +
                            (stats.protocolsUsed ?? 0).clamp(0, 5) +
                            (realSpinStreak > 30 ? 2 : (realSpinStreak > 7 ? 1 : 0)) +
                            (stats.totalXp > 5000 ? 2 : (stats.totalXp > 1000 ? 1 : 0));
        } else {
          actualBadgeCount = 0;
        }
      }

      if (mounted) {
        setState(() {
          _blockchainTxCount = actualTxCount;
          _totalBadgeCount = actualBadgeCount;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _blockchainTxCount = null;
          _totalBadgeCount = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingActivityData = false;
        });
      }
    }
  }

  Widget _buildRefreshLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF8B5CF6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Refreshing',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadDataFromCache() async {
    try {
      debugPrint('📦 Loading all data from cache...');

      final comprehensiveStats = await PlumeApiService().getComprehensiveWalletStats(widget.walletAddress, forceRefresh: false);

      await _loadPpTotalsData(forceRefresh: false);

      await _loadSkySocietyData(forceRefresh: false);

      await _loadWalletBalanceData(forceRefresh: false);

      await _loadActivityData();
      await _loadDailySpinData(forceRefresh: false);

      if (mounted) {
        setState(() {
          _comprehensiveStats = comprehensiveStats;
          if (comprehensiveStats != null) {
            _walletData = PlumeWalletData(
              walletAddress: widget.walletAddress,
              lastUpdated: DateTime.now(),
              isError: false,
            );
          }
          _lastRefresh = DateTime.now();
          _isDataLoadedFromCache = true;
          _isLoading = false;

          _updateBattleGroupRank(comprehensiveStats?.data.stats.battleGroup?.toString());
        });
      }

      debugPrint('✅ All data loaded from cache successfully');
    } catch (e) {
      debugPrint('❌ Error loading from cache: $e');
      await _loadWalletDataFromAPI();
    }
  }

  Future<void> _loadWalletDataFromAPI() async {
    setState(() {
      _isLoading = true;
      _isDataLoadedFromCache = false;
    });

    try {
      final data = await PlumeApiService().getWalletDetails(widget.walletAddress);

      final comprehensiveStats = await PlumeApiService().getComprehensiveWalletStats(widget.walletAddress);

      await _loadPpTotalsData();

      await _loadSkySocietyData();

      await _loadWalletBalanceData();

      await _loadActivityData();
      await _loadDailySpinData();

      if (mounted) {
        setState(() {
          _comprehensiveStats = comprehensiveStats;
          _walletData = data;
          _lastRefresh = DateTime.now();
          _isLoading = false;

          _updateBattleGroupRank(comprehensiveStats?.data.stats.battleGroup?.toString());
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _walletData = PlumeWalletData.error('Failed to load: $e');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    HapticFeedback.lightImpact();

    setState(() {
      _isRefreshing = true;
    });

    try {
      final cacheService = CacheService.instance;
      await cacheService.clearAllCacheForWallet(widget.walletAddress);

      debugPrint('🔄 Cache cleared, refreshing all data for ${widget.walletAddress}');

      final data = await PlumeApiService().getWalletDetails(widget.walletAddress);
      final comprehensiveStats = await PlumeApiService().getComprehensiveWalletStats(widget.walletAddress, forceRefresh: true);

      await _loadPpTotalsData(forceRefresh: true);
      await _loadSkySocietyData(forceRefresh: true);
      await _loadWalletBalanceData(forceRefresh: true);
      await _loadActivityData();
      await _loadDailySpinData(forceRefresh: true);

      if (mounted) {
        setState(() {
          _walletData = data;
          _comprehensiveStats = comprehensiveStats;
          _lastRefresh = DateTime.now();
          _isRefreshing = false;
          _isDataLoadedFromCache = false;

          _updateBattleGroupRank(comprehensiveStats?.data.stats.battleGroup?.toString());
        });

        debugPrint('✅ Data refreshed successfully without popup notifications');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });

        debugPrint('❌ Refresh failed: $e');
      }
    }
  }

  String _shortenAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatNumber(double? value) {
    if (value == null) return 'N/A';
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    } else {
      return value.toStringAsFixed(2);
    }
  }

  String _formatTvlNumber(double? value) {
    if (value == null) return 'N/A';
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    } else {
      return value.toStringAsFixed(2);
    }
  }

  void _copyReferralCodeSilent(String referralCode) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: referralCode));
  }

  void _copyDonationAddress(String address) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: address));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.coffee,
                color: Colors.amber.shade200,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Thank you! Address copied to clipboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  String _getTimeSinceRefresh() {
    if (_lastRefresh == null) return '';

    final diff = DateTime.now().difference(_lastRefresh!);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }

  void _updateBattleGroupRank(String? currentBattleGroup) {
    _previousBattleGroup = _currentBattleGroup;
    _currentBattleGroup = currentBattleGroup;
  }

  int _getRealDailySpinStreak() {
    final stats = _comprehensiveStats?.data.stats;
    if (stats == null) {
      return 0;
    }

    final int apiStreakValue = stats.dailySpinStreak ?? 0;

    if (_dailySpinData != null && _dailySpinData!.data.spins.isNotEmpty) {
      final int calculatedStreak = PortalWalletStats.calculateRealCurrentStreak(_dailySpinData!.data.spins);
      return calculatedStreak;
    }

    return apiStreakValue;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final plumePortalService = PlumePortalService();
        final portalStatsService = PortalStatsService();
        final nucleusEarnService = NucleusEarnService();

        final provider = PlumePortalProvider(
          plumePortalService,
          portalStatsService,
          nucleusEarnService,
        );

        Future.microtask(() async {
          try {
            print('🚀 Initializing services...');
            await Future.wait([
              plumePortalService.initialize(),
              portalStatsService.initialize(),
              nucleusEarnService.initialize(),
            ], eagerError: false);
            print('✅ All services initialized successfully');
          } catch (e) {
            print('⚠️ Service initialization warning: $e');
          }
        });

        return provider;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0B0F),
        extendBodyBehindAppBar: true,
        appBar: _buildModernAppBar(),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: _buildAnimatedBackground(),
            ),
            _buildBody(),
            if (_isRefreshing) _buildRefreshLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _walletData == null) {
      return _buildLoading();
    }

    if (_walletData == null) {
      return _buildInitialState();
    }

    if (_walletData!.isError) {
      return _buildError();
    }

    return _buildContent();
  }

  Widget _buildLoading() {
    return LoadingScreenFactory.createMinimal(
      message: 'Loading Portal Data',
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Portal Data...',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load Data',
              style: TextStyle(
                fontSize: 20,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _walletData!.errorMessage ?? 'Unknown error occurred',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedProfileHeader(),
          const SizedBox(height: 24),

          _buildPlumePointBreakdown(),
          const SizedBox(height: 24),

          PlumeBadgesWidget(
            walletAddress: widget.walletAddress,
            showTitle: true,
            maxBadgesToShow: 12,
          ),
          const SizedBox(height: 24),

          if (_comprehensiveStats != null) ...[ 
            _buildModernComprehensiveStatsCards(),
            const SizedBox(height: 24),
          ] else ...[ 
            _buildFallbackContent(),
            const SizedBox(height: 24),
          ],

          _buildModernLastUpdateInfo(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFallbackContent() {
    final data = _walletData!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.balance != null) ...[
          _buildBalanceCard(),
          const SizedBox(height: 16),
        ],

        if (data.portfolioStats != null) ...[
          _buildPortfolioStatsCard(),
          const SizedBox(height: 16),
        ],

        if (data.predictions != null && data.predictions!.isNotEmpty) ...[
          _buildPredictionsCard(),
          const SizedBox(height: 16),
        ],

        if (data.rewards != null) ...[
          _buildRewardsCard(),
          const SizedBox(height: 16),
        ],

        if (data.rankings != null) ...[
          _buildRankingsCard(),
          const SizedBox(height: 16),
        ],

        if (data.activityHistory != null) ...[
          _buildActivityHistoryCard(),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Balance',
                  style: AppFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_formatNumber(_walletData!.balance)} ETH',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioStatsCard() {
    final stats = _walletData!.portfolioStats!;

    return Card(
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Colors.purple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Portfolio Statistics',
                  style: AppFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...stats.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsCard() {
    final predictions = _walletData!.predictions!;

    return Card(
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Predictions (${predictions.length})',
                  style: AppFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...predictions.take(5).map((prediction) => _buildPredictionItem(prediction)),
            if (predictions.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'And ${predictions.length - 5} more predictions...',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem(PredictionData prediction) {
    Color statusColor = Colors.grey;
    if (prediction.status == 'won') statusColor = Colors.green;
    if (prediction.status == 'lost') statusColor = Colors.red;
    if (prediction.status == 'pending') statusColor = Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (prediction.market != null)
              Text(
                prediction.market!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (prediction.prediction != null)
              Text(
                'Prediction: ${prediction.prediction}',
                style: const TextStyle(color: Colors.white70),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (prediction.stake != null)
                  Text(
                    'Stake: ${_formatNumber(prediction.stake)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                Text(
                  prediction.status ?? 'Unknown',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsCard() {
    final rewards = _walletData!.rewards!;

    return Card(
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Rewards',
                  style: AppFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...rewards.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingsCard() {
    final rankings = _walletData!.rankings!;

    return Card(
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.leaderboard,
                  color: Colors.cyan,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Rankings',
                  style: AppFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...rankings.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '#${entry.value}',
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityHistoryCard() {
    final activity = _walletData!.activityHistory!;

    return Card(
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.teal,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Activity History',
                  style: AppFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...activity.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.all(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(8),
            splashColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
            highlightColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1).withValues(alpha: 0.8),
              const Color(0xFF8B5CF6).withValues(alpha: 0.6),
              const Color(0xFF06B6D4).withValues(alpha: 0.4),
            ],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0B0F).withValues(alpha: 0.7),
          ),
        ),
      ),
      centerTitle: true,
      title: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth - 120;

          return Container(
            width: availableWidth,
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                'PLUME PORTAL',
                style: AppFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: (_isLoading || _isRefreshing) ? null : _refreshData,
              borderRadius: BorderRadius.circular(8),
              splashColor: const Color(0xFF06B6D4).withValues(alpha: 0.2),
              highlightColor: const Color(0xFF06B6D4).withValues(alpha: 0.1),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _isRefreshing 
                      ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                      : const Color(0xFF06B6D4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isRefreshing
                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
                        : const Color(0xFF06B6D4).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: _isRefreshing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF8B5CF6),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.sync_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAnimatedBackground() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 2.0,
            colors: [
              const Color(0xFF6366F1).withValues(alpha: 0.1),
              const Color(0xFF8B5CF6).withValues(alpha: 0.05),
              const Color(0xFF06B6D4).withValues(alpha: 0.03),
              const Color(0xFF0A0B0F),
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedProfileHeader() {
    final stats = _comprehensiveStats?.data.stats;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1),
                      const Color(0xFF8B5CF6),
                      const Color(0xFF06B6D4),
                    ],
                  ),
                ),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E1E1E),
                    border: Border.all(
                      color: const Color(0xFF0A0B0F),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF6366F1).withValues(alpha: 0.8),
                            const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/goon-profile.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.account_circle,
                              size: 32,
                              color: Colors.white70,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Portal User',
                        style: AppFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.walletAddress.substring(0, 6)}...${widget.walletAddress.substring(widget.walletAddress.length - 4)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAssetsWidget(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSkySocietyTierCard(),
              ),
            ],
          ),

          if (stats != null) ...[ 
            const SizedBox(height: 20),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildResponsiveQuickStatItem(
                        'Total PP',
                        _formatNumber(stats.totalXp.toDouble()),
                        Icons.stars,
                        const Color(0xFFFFB800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildResponsiveQuickStatItem(
                        'PP Rank',
                        '#${stats.xpRank}',
                        Icons.leaderboard,
                        const Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildResponsiveQuickStatItem(
                        'TVL',
                        '\$${_formatTvlNumber(stats.tvl)}',
                        Icons.account_balance,
                        const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildResponsiveQuickStatItem(
                        'Quest',
                        '${stats.completedQuests ?? 0}',
                        Icons.assignment_turned_in,
                        const Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildResponsiveQuickStatItem(
                        'Spin Streak',
                        '${_getRealDailySpinStreak()}d',
                        Icons.casino,
                        const Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildResponsiveQuickStatItem(
                        'Referrals',
                        '${stats.totalReferrals ?? 0}',
                        Icons.people,
                        const Color(0xFF06B6D4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResponsiveQuickStatItem(String title, String value, IconData icon, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 100;
        final double iconSize = isNarrow ? 16 : 20;
        final double valueSize = isNarrow ? 12 : 14;
        final double titleSize = isNarrow ? 9 : 10;
        final double padding = isNarrow ? 8 : 12;
        final double spacing = isNarrow ? 4 : 6;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: iconSize,
              ),
              SizedBox(height: spacing),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: isNarrow ? 2 : 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: isNarrow ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssetsWidget() {
    if (_isLoadingWalletBalance) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading assets...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_walletBalanceData == null) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white.withValues(alpha: 0.5),
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load assets',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_walletBalanceData!.tokens.isEmpty || _walletBalanceData!.totalUSDValue <= 0) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: const Color(0xFF10B981).withValues(alpha: 0.5),
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              'No assets found',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final walletBalance = _walletBalanceData!;
    final totalUsdValue = walletBalance.totalUSDValue;
    final tokenCount = walletBalance.tokens.length;

    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.15),
            const Color(0xFF059669).withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF10B981),
                      const Color(0xFF059669),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assets',
                      style: AppFonts.orbitron(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tokenCount} tokens',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\$${_formatNumber(totalUsdValue)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'USD',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkySocietyTierCard() {
    if (_isLoadingSkySociety) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading tier...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    final skySocietyData = _skySocietyData?.data;
    final tierValue = skySocietyData?.skySocietyTier;
    final hasValidTier = tierValue != null && tierValue.isNotEmpty && tierValue != 'null';

    if (!hasValidTier) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.visibility_off,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Sky Society',
                          style: AppFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Tier Status',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'NO TIER',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.4),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      'INACTIVE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final displayTier = tierValue!;

    Color tierColor;
    String? tierImagePath;
    IconData tierIcon;

    switch (displayTier.toLowerCase()) {
      case 'phoenix':
        tierColor = const Color(0xFFFF4500);
        tierImagePath = 'assets/tier/phoenix.avif';
        tierIcon = Icons.whatshot;
        break;
      case 'eagle':
        tierColor = const Color(0xFFD2691E);
        tierImagePath = 'assets/tier/eagle.avif';
        tierIcon = Icons.keyboard_double_arrow_up;
        break;
      case 'hawk':
        tierColor = const Color(0xFF8B7355);
        tierImagePath = 'assets/tier/hawk.avif';
        tierIcon = Icons.remove_red_eye;
        break;
      case 'falcon':
        tierColor = const Color(0xFF4A90E2);
        tierImagePath = 'assets/tier/falcon.avif';
        tierIcon = Icons.bolt;
        break;
      case 'raven':
        tierColor = const Color(0xFF2F2F2F);
        tierImagePath = 'assets/tier/raven.avif';
        tierIcon = Icons.dark_mode;
        break;
      case 'pigeon':
        tierColor = const Color(0xFF708090);
        tierImagePath = 'assets/tier/pigeon.avif';
        tierIcon = Icons.flight;
        break;
      case 'sparrow':
        tierColor = const Color(0xFF8B4513);
        tierImagePath = 'assets/tier/sparrow.avif';
        tierIcon = Icons.pets;
        break;
      case 'egg':
        tierColor = const Color(0xFFF5F5F5);
        tierImagePath = 'assets/tier/egg.avif';
        tierIcon = Icons.egg;
        break;
      case 'gold':
        tierColor = const Color(0xFFFFD700);
        tierImagePath = null;
        tierIcon = Icons.star;
        break;
      case 'silver':
        tierColor = const Color(0xFFC0C0C0);
        tierImagePath = null;
        tierIcon = Icons.star_border;
        break;
      case 'bronze':
        tierColor = const Color(0xFFCD7F32);
        tierImagePath = null;
        tierIcon = Icons.star_outline;
        break;
      case 'platinum':
        tierColor = const Color(0xFFE5E4E2);
        tierImagePath = null;
        tierIcon = Icons.workspace_premium;
        break;
      case 'diamond':
        tierColor = const Color(0xFFB9F2FF);
        tierImagePath = null;
        tierIcon = Icons.diamond;
        break;
      default:
        tierColor = const Color(0xFF8B5CF6);
        tierImagePath = null;
        tierIcon = Icons.military_tech;
    }

    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tierColor.withValues(alpha: 0.15),
            tierColor.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tierColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tierColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: tierColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: tierImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          tierImagePath!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: tierColor.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                tierIcon,
                                color: tierColor,
                                size: 20,
                              ),
                            );
                          },
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            return child;
                          },
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              tierColor,
                              tierColor.withValues(alpha: 0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          tierIcon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Sky Society',
                        style: AppFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Tier Status',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      displayTier.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        color: tierColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: tierColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    hasValidTier ? 'ACTIVE' : 'DEFAULT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(String title, String value, IconData icon, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 100;
        final double iconSize = isNarrow ? 16 : 20;
        final double valueSize = isNarrow ? 12 : 14;
        final double titleSize = isNarrow ? 9 : 10;
        final double padding = isNarrow ? 8 : 12;
        final double spacing = isNarrow ? 4 : 6;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: iconSize,
              ),
              SizedBox(height: spacing),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              SizedBox(height: isNarrow ? 2 : 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: isNarrow ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernComprehensiveStatsCards() {
    final response = _comprehensiveStats!;
    final stats = response.data.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _buildWalletBalanceWidget(),
        const SizedBox(height: 16),

        _buildEnhancedPortfolioWidget(),
        const SizedBox(height: 16),

        _buildDailySpinDataWidget(),
        const SizedBox(height: 16),

        _buildEnhancedFinancialMetricsCard(stats),
        const SizedBox(height: 16),

        _buildEnhancedActivityCard(stats),
        const SizedBox(height: 16),

        _buildStakingRewardReportCard(stats),
        const SizedBox(height: 16),

          Season1Widget(
            walletAddress: widget.walletAddress,
            showTitle: true,
            battleGroup: stats.battleGroup,
            bgRank: stats.bgRank,
          ),
          const SizedBox(height: 16),

        if (stats.referralCode.isNotEmpty) ...[
          _buildCompactReferralCard(stats.referralCode),
        ],
      ],
    );
  }

  Widget _buildWalletBalanceWidget() {
    if (widget.walletAddress.isEmpty) {
      return Container();
    }
    return EnsoWalletBalancesWidget(
      walletAddress: widget.walletAddress,
    );
  }

  Widget _buildEnhancedPortfolioWidget() {
    return Consumer<PlumePortalProvider>(
      builder: (context, provider, child) {
        if (!provider.isPortfolioLoading && 
            !provider.hasPortfolioData && 
            !provider.hasPortfolioError &&
            provider.portfolioState.currentWalletAddress != widget.walletAddress) {
          Future.microtask(() {
            provider.loadPortfolio(widget.walletAddress);
          });
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF06B6D4),
                          const Color(0xFF0891B2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_tree,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Other Portfolio',
                            style: AppFonts.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _buildPortfolioStatusText(provider),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (provider.isPortfolioLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
                      ),
                    )
                  else if (provider.hasPortfolioData)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF10B981).withValues(alpha: 0.2),
                            const Color(0xFF059669).withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              _buildEnhancedPortfolioContent(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedPortfolioContent(PlumePortalProvider provider) {
    if (provider.isPortfolioLoading) {
      return PortfolioLoadingView();
    }

    if (provider.hasPortfolioError) {
      return PortfolioErrorView(
        error: provider.portfolioErrorMessage ?? 'Unknown portfolio error',
        onRetry: () {
          provider.loadPortfolio(widget.walletAddress);
        },
      );
    }

    if (!provider.hasPortfolioData || 
        provider.portfolioData == null || 
        provider.portfolioData!.isEmpty) {
      return PortfolioEmptyView(
        walletAddress: widget.walletAddress,
        onRefresh: () {
          provider.loadPortfolio(widget.walletAddress);
        },
      );
    }

    final portfolioResponse = provider.portfolioData!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        PortfolioSummaryCard(
          portfolio: portfolioResponse,
          isLoading: false,
        ),

        const SizedBox(height: 16),

        if (portfolioResponse.topAssets.isNotEmpty) ...[
          TopAssetsCard(
            topAssets: portfolioResponse.topAssets,
            totalValue: portfolioResponse.totalValue,
          ),
          const SizedBox(height: 16),
        ],

        if (portfolioResponse.portfolioItems.isNotEmpty) ...[
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'All Holdings (${portfolioResponse.portfolioItems.length})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),

          ...portfolioResponse.portfolioItems
              .take(5)
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PortfolioItemCard(
                      item: item,
                      totalPortfolioValue: portfolioResponse.totalValueUsd,
                    ),
                  ))
              .toList(),

          if (portfolioResponse.portfolioItems.length > 5)
            Container(
              margin: const EdgeInsets.only(top: 12),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showAllPortfolioItemsFromProvider(context, portfolioResponse);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility,
                            color: const Color(0xFF06B6D4),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'View All ${portfolioResponse.portfolioItems.length - 5} More Holdings',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],

        const SizedBox(height: 16),

        Builder(
          builder: (context) {
            try {
              final PortfolioStats stats = PortfolioStats.fromPortfolio(portfolioResponse);
              return PortfolioStatsCard(
                stats: stats,
              );
            } catch (e) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Portfolio statistics unavailable',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }

  void _showAllPortfolioItemsFromProvider(BuildContext context, UserPortfolioResponse portfolioResponse) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0B0F),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      const Color(0xFF7C3AED).withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF8B5CF6),
                                const Color(0xFF7C3AED),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.pie_chart,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'All Portfolio Holdings',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${portfolioResponse.portfolioItems.length} assets • ${portfolioResponse.formattedTotalValue}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: portfolioResponse.portfolioItems.length,
                  itemBuilder: (context, index) {
                    final item = portfolioResponse.portfolioItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildSimplePortfolioItem(item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimplePortfolioItem(PortfolioItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(item.tokenColor).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.tokenSymbol.length > 2 
                      ? item.tokenSymbol.substring(0, 2).toUpperCase()
                      : item.tokenSymbol.toUpperCase(),
                  style: TextStyle(
                    color: Color(item.tokenColor),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.tokenName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${item.formattedBalance} ${item.tokenSymbol}',
                    style: TextStyle(
                      color: Colors.grey[400], 
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.formattedTotalValue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlumePointBreakdown() {
    if (_ppScores == null) {
      return const SizedBox.shrink();
    }

    final ppScores = _ppScores!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6),
                      const Color(0xFF7C3AED),
                      const Color(0xFF6366F1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.stars, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plume Points Breakdown',
                      style: AppFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF10B981).withValues(alpha: 0.3),
                                const Color(0xFF059669).withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.fiber_manual_record,
                          color: Color(0xFF10B981),
                          size: 8,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Real-time data from pp-totals',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildPlumePointCard(
                  'Active PP',
                  _formatXp(ppScores.activeXp.totalXp),
                  ppScores.activeXp.formattedDate,
                  Colors.white,
                  Icons.flash_on,
                  isActive: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPlumePointCard(
                  'Previous PP',
                  _formatXp(ppScores.prevXp.totalXp),
                  ppScores.prevXp.formattedDate,
                  Colors.white70,
                  Icons.history,
                  isActive: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1),
                            const Color(0xFF8B5CF6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getGrowthPercentage() >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Growth Analysis',
                            style: AppFonts.orbitron(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Performance trend & metrics',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getGrowthPercentage() >= 0
                              ? [
                                  const Color(0xFF10F993).withValues(alpha: 0.2),
                                  const Color(0xFF10B981).withValues(alpha: 0.15),
                                ]
                              : [
                                  const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                                  const Color(0xFFEF4444).withValues(alpha: 0.15),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _getGrowthPercentage() >= 0
                              ? const Color(0xFF10F993).withValues(alpha: 0.4)
                              : const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getGrowthPercentage() >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                            color: _getGrowthPercentage() >= 0 ? const Color(0xFF10F993) : const Color(0xFFFF6B6B),
                            size: 10,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _getGrowthPercentage() >= 0 ? 'UP' : 'DOWN',
                            style: TextStyle(
                              color: _getGrowthPercentage() >= 0 ? const Color(0xFF10F993) : const Color(0xFFFF6B6B),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _getXpDelta() >= 0
                                ? [
                                    const Color(0xFF10F993).withValues(alpha: 0.1),
                                    const Color(0xFF10B981).withValues(alpha: 0.05),
                                  ]
                                : [
                                    const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                                    const Color(0xFFEF4444).withValues(alpha: 0.05),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getXpDelta() >= 0
                                ? const Color(0xFF10F993).withValues(alpha: 0.3)
                                : const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getXpDelta() >= 0 ? Icons.north : Icons.south,
                                  color: _getXpDelta() >= 0 ? const Color(0xFF10F993) : const Color(0xFFFF6B6B),
                                  size: 14,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    'PP Delta',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_getXpDelta() >= 0 ? '+' : ''}${_formatXp(_getXpDelta())}',
                              style: TextStyle(
                                color: _getXpDelta() >= 0 ? const Color(0xFF10F993) : const Color(0xFFFF6B6B),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _getGrowthPercentage() >= 0
                                ? [
                                    const Color(0xFF6366F1).withValues(alpha: 0.1),
                                    const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                                  ]
                                : [
                                    const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                                    const Color(0xFFEF4444).withValues(alpha: 0.05),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getGrowthPercentage() >= 0
                                ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                                : const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getGrowthPercentage() >= 0 ? Icons.trending_up : Icons.trending_down,
                                  color: _getGrowthPercentage() >= 0 ? const Color(0xFF6366F1) : const Color(0xFFFF6B6B),
                                  size: 14,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    'Growth Rate',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatGrowthPercentage(_getGrowthPercentage()),
                              style: TextStyle(
                                color: _getGrowthPercentage() >= 0 ? const Color(0xFF6366F1) : const Color(0xFFFF6B6B),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insights,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _getGrowthInsight(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (ppScores.activeXp != null)
            _buildXpBreakdownSection(ppScores.activeXp!),

          if (ppScores.top3PointsDeltasStrings.isNotEmpty) ...
            _buildTopDeltasPreview(ppScores.top3PointsDeltasStrings),
        ],
      ),
    );
  }

  Widget _buildPlumePointCard(String title, String value, String date, Color textColor, IconData icon, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive 
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive 
              ? Colors.white.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildXpBreakdownSection(XpData activeXp) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.analytics, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            const Text(
              'PP Breakdown',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBreakdownItem(
                'Self PP',
                activeXp.userSelfXp,
                Icons.person,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBreakdownItem(
                'Referral PP',
                activeXp.referralBonusXp,
                Icons.people,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBreakdownItem(
                'Total PP',
                activeXp.totalXp,
                Icons.star,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBreakdownItem(String title, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTopDeltasPreview(List<String> deltas) {
    return [
      const SizedBox(height: 12),
      Row(
        children: [
          const Icon(Icons.insights, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          const Text(
            'Top Point Deltas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 6,
        children: deltas.take(3).map((delta) => 
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              delta,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ).toList(),
      ),
    ];
  }

  String _formatXp(int xp) {
    if (xp >= 1000000) {
      return '${(xp / 1000000).toStringAsFixed(2)}M';
    } else if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}K';
    } else {
      return xp.toString();
    }
  }

  int _getXpDelta() {
    if (_activeXp == null || _prevXp == null) return 0;
    return _activeXp!.totalXp - _prevXp!.totalXp;
  }

  double _getGrowthPercentage() {
    if (_activeXp == null || _prevXp == null || _prevXp!.totalXp == 0) return 0.0;
    return ((_activeXp!.totalXp - _prevXp!.totalXp) / _prevXp!.totalXp) * 100;
  }

  String _formatGrowthPercentage(double percentage) {
    return '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(1)}%';
  }

  String _getGrowthInsight() {
    final growth = _getGrowthPercentage();
    final delta = _getXpDelta();

    if (growth > 50) {
      return 'Excellent growth! You\'re performing exceptionally well.';
    } else if (growth > 20) {
      return 'Strong positive momentum. Keep up the great work!';
    } else if (growth > 5) {
      return 'Steady growth trajectory. You\'re on the right track.';
    } else if (growth > 0) {
      return 'Gradual improvement. Small gains add up over time.';
    } else if (growth == 0) {
      return 'Stable performance. Consider new strategies for growth.';
    } else if (growth > -10) {
      return 'Minor decline. Focus on recovery and optimization.';
    } else {
      return 'Significant drop. Review your strategy and adapt.';
    }
  }

  BattleGroupRankChange _getBattleGroupRankChange() {
    if (_previousBattleGroup == null || _currentBattleGroup == null) {
      return BattleGroupRankChange.none;
    }

    final prevRank = _extractRankFromBattleGroup(_previousBattleGroup!);
    final currentRank = _extractRankFromBattleGroup(_currentBattleGroup!);

    if (prevRank == null || currentRank == null) {
      return BattleGroupRankChange.none;
    }

    if (currentRank < prevRank) {
      return BattleGroupRankChange.up;
    } else if (currentRank > prevRank) {
      return BattleGroupRankChange.down;
    } else {
      return BattleGroupRankChange.stable;
    }
  }

  int? _extractRankFromBattleGroup(String battleGroup) {
    final RegExp numberRegex = RegExp(r'\d+');
    final match = numberRegex.firstMatch(battleGroup);

    if (match != null) {
      return int.tryParse(match.group(0)!);
    }

    return null;
  }

  String _buildPortfolioStatusText(PlumePortalProvider provider) {
    try {
      if (provider.isPortfolioLoading) {
        return 'Loading portfolio data...';
      } else if (provider.hasPortfolioError) {
        return 'Failed to load portfolio';
      } else if (provider.hasPortfolioData) {
        final summary = provider.portfolioSummary;
        if (summary != null && summary.isNotEmpty && summary != 'null') {
          return summary;
        } else {
          return 'Portfolio data available';
        }
      } else {
        return 'Real-time portfolio tracking';
      }
    } catch (e) {
      return 'Real-time portfolio tracking';
    }
  }

  Widget _buildPortfolioWidget() {
    final walletBalance = _walletBalanceData;
    final stats = _comprehensiveStats?.data.stats;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF06B6D4),
                      const Color(0xFF0891B2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_tree,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portfolio Overview',
                      style: AppFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      walletBalance != null
                          ? 'Token holdings • ${walletBalance.totalTokenCount} assets'
                          : 'Token holdings and analytics',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              if (walletBalance != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981).withValues(alpha: 0.2),
                        const Color(0xFF059669).withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (walletBalance != null)
            _buildPortfolioSummary(walletBalance)
          else if (_isLoadingWalletBalance)
            _buildPortfolioLoading()
          else
            _buildPortfolioPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary(WalletBalanceResponse walletBalance) {
    final allTokens = walletBalance.tokens;
    final significantTokens = walletBalance.significantTokens;
    final displayTokens = _showAllTokens ? allTokens : significantTokens.take(3).toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPortfolioMetricCard(
                'Total Value',
                '\$${walletBalance.formattedTotalValue}',
                Icons.account_balance_wallet,
                const Color(0xFF10B981),
                'USD value',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPortfolioMetricCard(
                'Assets',
                '${walletBalance.totalTokenCount}',
                Icons.pie_chart_outline,
                const Color(0xFF06B6D4),
                'tokens held',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPortfolioMetricCard(
                'Significant',
                '${walletBalance.significantTokenCount}',
                Icons.star_outline,
                const Color(0xFFFFB800),
                'valuable assets',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (displayTokens.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                _showAllTokens ? Icons.list : Icons.trending_up,
                color: const Color(0xFF06B6D4),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _showAllTokens ? 'All Tokens' : 'Top Holdings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _showAllTokens 
                    ? '${displayTokens.length} of ${walletBalance.totalTokenCount}'
                    : 'Top ${displayTokens.length} of ${walletBalance.totalTokenCount}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showAllTokens = !_showAllTokens;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF06B6D4).withValues(alpha: 0.2),
                        const Color(0xFF0891B2).withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showAllTokens ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF06B6D4),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showAllTokens ? 'Less' : 'All',
                        style: TextStyle(
                          color: const Color(0xFF06B6D4),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _showAllTokens 
              ? Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Column(
                      children: displayTokens.map((token) => _buildTopTokenItem(token)).toList(),
                    ),
                  ),
                )
              : Column(
                  children: displayTokens.map((token) => _buildTopTokenItem(token)).toList(),
                ),
        ],
      ],
    );
  }

  Widget _buildPortfolioMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTopTokenItem(TokenBalance token) {
    String displayName = token.name != null && token.name!.isNotEmpty 
        ? token.name!
        : token.symbol;

    if (displayName.length > 30) {
      displayName = '${displayName.substring(0, 27)}...';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF06B6D4).withValues(alpha: 0.3),
                      const Color(0xFF0891B2).withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    token.symbol.isNotEmpty 
                        ? token.symbol.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                flex: 2,
                child: Text(
                  token.symbol,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  token.formattedUsdValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if ((token.name?.length ?? 0) > 30)
                      const SizedBox(height: 2),
                    if ((token.name?.length ?? 0) > 30)
                      Text(
                        'Tap to see full name',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  token.formattedBalance,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioLoading() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF06B6D4),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Loading portfolio data...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_tree_outlined,
            color: Colors.white.withValues(alpha: 0.6),
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Portfolio Data',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Token holdings will appear here once data is available',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildDailySpinDataWidget() {
    if (_isLoadingDailySpinData) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Loading Daily Spin Data...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_dailySpinData == null || _dailySpinData!.data.spins.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF6B35),
                        const Color(0xFFE63946),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.casino,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Daily Spin History',
                    style: AppFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'No daily spin records available',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final spinData = _dailySpinData!.data;
    final spinRecords = spinData.spins;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B35),
                      const Color(0xFFE63946),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.casino,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Spin History',
                      style: AppFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Daily spin rewards and history • ${spinRecords.length} records',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF10B981).withValues(alpha: 0.2),
                      const Color(0xFF059669).withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildSpinSummaryRow(spinRecords),
          const SizedBox(height: 20),

          Row(
            children: [
              Icon(
                Icons.history,
                color: const Color(0xFFFF6B35),
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Recent Spins',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (spinRecords.length > 5)
                Text(
                  'Showing last 5 of ${spinRecords.length}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          Column(
            children: spinRecords
                .take(5)
                .map((record) => _buildSpinRecordItem(record))
                .toList(),
          ),

          Builder(
            builder: (context) {
              final bool hasMoreRecords = spinRecords.length > 5;
              final int moreRecordsCount = spinRecords.length - 5;

              if (!hasMoreRecords || moreRecordsCount <= 0) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showAllSpinRecords(context, spinRecords);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility,
                                color: const Color(0xFFFF6B35),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'View All $moreRecordsCount More Records',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: const Color(0xFFFF6B35).withValues(alpha: 0.8),
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpinSummaryRow(List<SpinRecord> spinRecords) {
    final int totalSpins = spinRecords.length;
    final int recentSpins = spinRecords.where((record) {
      final recordDate = record.dateTime;
      if (recordDate == null) return false;
      final daysDiff = DateTime.now().difference(recordDate).inDays;
      return daysDiff <= 7;
    }).length;

    final int currentStreak = _calculateRealCurrentStreak(spinRecords);

    return Row(
      children: [
        Expanded(
          child: _buildSpinSummaryItem(
            'Total Spins',
            totalSpins.toString(),
            Icons.casino,
            const Color(0xFFFF6B35),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSpinSummaryItem(
            'This Week',
            recentSpins.toString(),
            Icons.date_range,
            const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSpinSummaryItem(
            'Current Streak',
            '${currentStreak}d',
            Icons.local_fire_department,
            const Color(0xFFFFB800),
          ),
        ),
      ],
    );
  }

  int _calculateRealCurrentStreak(List<SpinRecord> spinRecords) {
    final streak = PortalWalletStats.calculateRealCurrentStreak(spinRecords);
    return streak;
  }

  Widget _buildSpinSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 80;
        final double iconSize = isNarrow ? 14 : 18;
        final double valueSize = isNarrow ? 11 : 13;
        final double labelSize = isNarrow ? 8 : 9;
        final double verticalPadding = isNarrow ? 8 : 10;
        final double horizontalPadding = isNarrow ? 6 : 8;

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: iconSize,
              ),
              SizedBox(height: isNarrow ? 4 : 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: valueSize,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
              SizedBox(height: isNarrow ? 2 : 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: labelSize,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpinRecordItem(SpinRecord record) {
    final DateTime? spinDateNullable = record.dateTime;
    if (spinDateNullable == null) {
      return Container();
    }
    final DateTime spinDate = spinDateNullable;
    final String formattedDate = _formatSpinDate(spinDate);

    final int daysSince = DateTime.now().difference(spinDate).inDays;
    Color recordColor;
    if (daysSince == 0) {
      recordColor = const Color(0xFF10B981);
    } else if (daysSince <= 3) {
      recordColor = const Color(0xFFFFB800);
    } else if (daysSince <= 7) {
      recordColor = const Color(0xFF8B5CF6);
    } else {
      recordColor = const Color(0xFF6B7280);
    }

    final String rewardDisplay = record.reward.hasReward
        ? '+${record.reward.formattedAmount}'
        : 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: recordColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: recordColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.calendar_today,
              color: recordColor,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.reward.displayText.isNotEmpty ? record.reward.displayText : 'Daily spin completed',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: recordColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rewardDisplay,
              style: TextStyle(
                color: recordColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Text(
            daysSince == 0 ? 'Today' : '${daysSince}d ago',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSpinDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final spinDay = DateTime(date.year, date.month, date.day);

    final daysDifference = today.difference(spinDay).inDays;

    if (daysDifference == 0) {
      return 'Today • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (daysDifference == 1) {
      return 'Yesterday';
    } else if (daysDifference < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAllSpinRecords(BuildContext context, List<SpinRecord> spinRecords) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0B0F),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B35).withValues(alpha: 0.1),
                      const Color(0xFFE63946).withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFF6B35),
                                const Color(0xFFE63946),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.casino,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'All Spin Records',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${spinRecords.length} total records',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: spinRecords.length,
                  itemBuilder: (context, index) {
                    final record = spinRecords[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildSpinRecordItem(record),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedFinancialMetricsCard(dynamic stats) {
    final bool hasData = stats != null && 
                        (stats.tvlTotalUsd > 0 || 
                         stats.bridgedTotal > 0 || 
                         stats.swapVolume > 0 || 
                         stats.swapCount > 0);

    final Color statusColor = hasData ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final String statusLabel = hasData ? 'LIVE' : 'NO DATA';
    final String serviceStatus = hasData ? 'Service status' : 'Data unavailable';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasData ? [
                      const Color(0xFF10B981),
                      const Color(0xFF059669),
                      const Color(0xFF047857),
                    ] : [
                      const Color(0xFFEF4444),
                      const Color(0xFFDC2626),
                      const Color(0xFFB91C1C),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Text(
              'Financial Metrics',
              style: AppFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                statusColor.withValues(alpha: 0.3),
                                statusColor.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.fiber_manual_record,
                          color: statusColor,
                          size: 8,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          serviceStatus,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 300) {
                return Column(
                  children: [
                    _buildTradingMetricItem(
                      'Total Value Locked',
                      hasData ? '\$${_formatTvlNumber(stats.tvlTotalUsd)}' : 'No Data',
                      Icons.account_balance_wallet,
                      hasData ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      'TVL',
                      hasData,
                    ),
                    const SizedBox(height: 12),
                    _buildTradingMetricItem(
                      'Bridged Assets',
                      hasData ? '\$${_formatNumber(stats.bridgedTotal)}' : 'No Data',
                      Icons.swap_horizontal_circle,
                      hasData ? const Color(0xFF8B5CF6) : const Color(0xFFEF4444),
                      'BRG',
                      hasData,
                    ),
                    const SizedBox(height: 12),
                    _buildTradingMetricItem(
                      'Swap Activity',
                      hasData ? '${stats.swapCount ?? 0} Swaps' : 'No Data',
                      Icons.currency_exchange,
                      hasData ? const Color(0xFF06B6D4) : const Color(0xFFEF4444),
                      'VOL',
                      hasData,
                    ),
                    const SizedBox(height: 12),
                    _buildTradingMetricItem(
                      'Transactions',
                      hasData ? '${stats.swapCount ?? 0}' : 'No Data',
                      Icons.repeat,
                      hasData ? const Color(0xFFFFB800) : const Color(0xFFEF4444),
                      'TXN',
                      hasData,
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTradingMetricItem(
                          'Total Value Locked',
                          hasData ? '\$${_formatTvlNumber(stats.tvlTotalUsd)}' : 'No Data',
                          Icons.account_balance_wallet,
                          hasData ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          'TVL',
                          hasData,
                        ),
                      ),
                      SizedBox(width: constraints.maxWidth < 500 ? 8 : 16),
                      Expanded(
                        child: _buildTradingMetricItem(
                          'Bridged Assets',
                          hasData ? '\$${_formatNumber(stats.bridgedTotal)}' : 'No Data',
                          Icons.swap_horizontal_circle,
                          hasData ? const Color(0xFF8B5CF6) : const Color(0xFFEF4444),
                          'BRG',
                          hasData,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: constraints.maxWidth < 500 ? 12 : 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTradingMetricItem(
                          'Swap Activity',
                          hasData ? '${stats.swapCount ?? 0} Swaps' : 'No Data',
                          Icons.currency_exchange,
                          hasData ? const Color(0xFF06B6D4) : const Color(0xFFEF4444),
                          'VOL',
                          hasData,
                        ),
                      ),
                      SizedBox(width: constraints.maxWidth < 500 ? 8 : 16),
                      Expanded(
                        child: _buildTradingMetricItem(
                          'Transactions',
                          hasData ? '${stats.swapCount ?? 0}' : 'No Data',
                          Icons.repeat,
                          hasData ? const Color(0xFFFFB800) : const Color(0xFFEF4444),
                          'TXN',
                          hasData,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTradingMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
    String symbol,
    bool isPositive,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 140;
        final double padding = isNarrow ? 12 : 16;
        final double iconSize = isNarrow ? 14 : 16;
        final double symbolSize = isNarrow ? 10 : 12;
        final double valueSize = isNarrow ? 16 : 18;
        final double labelSize = isNarrow ? 10 : 11;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(
                builder: (context, headerConstraints) {
                  if (headerConstraints.maxWidth < 120) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              icon,
                              color: color,
                              size: iconSize,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  symbol,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: symbolSize,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        _buildTrendIndicator(isPositive, isNarrow),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Icon(
                        icon,
                        color: color,
                        size: iconSize,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            symbol,
                            style: TextStyle(
                              color: color,
                              fontSize: symbolSize,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      _buildTrendIndicator(isPositive, isNarrow),
                    ],
                  );
                },
              ),
              SizedBox(height: isNarrow ? 8 : 12),

              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: valueSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),

              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: labelSize,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: isNarrow ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendIndicator(bool isPositive, bool isNarrow) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 3 : 4, 
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.green : Colors.red,
            size: isNarrow ? 8 : 10,
          ),
          SizedBox(width: isNarrow ? 1 : 2),
          Text(
            isPositive ? '+' : '-',
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontSize: isNarrow ? 7 : 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @Deprecated('These methods are no longer used since we display info-only data')
  bool _getTradingTrend(double value) {
    return value.toString().hashCode % 2 == 0;
  }

  @Deprecated('These methods are no longer used since we display info-only data')
  bool _getTradingTrendFromCount(int count) {
    return count % 2 == 1;
  }

  Widget _buildStakingRewardReportCard(dynamic stats) {
    final bool hasStakingData = stats != null && 
                               (stats.currentPlumeStakingTotalTokens > 0 ||
                                stats.plumeRewards?.totalPLUME > 0 ||
                                stats.plumeStakingStreak > 0 ||
                                stats.referralBonusXp > 0);

    final Color stakingStatusColor = hasStakingData ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final String stakingStatusLabel = hasStakingData ? 'ACTIVE' : 'INACTIVE';
    final String stakingPerformanceText = hasStakingData ? 'Live Performance' : 'No Activity';
    final IconData stakingIcon = hasStakingData ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6),
                      const Color(0xFF7C3AED),
                      const Color(0xFF6366F1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Staking & Rewards',
                      style: AppFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                stakingStatusColor.withValues(alpha: 0.3),
                                stakingStatusColor.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: stakingStatusColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            stakingStatusLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          stakingIcon,
                          color: stakingStatusColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stakingPerformanceText,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: stakingStatusColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: stakingStatusColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  Icons.fiber_manual_record,
                  color: stakingStatusColor,
                  size: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildReportMetricCard(
                      'PLUME Staked',
                      '${_formatNumber(stats.currentPlumeStakingTotalTokens)} PLUME',
                      Icons.lock,
                      const Color(0xFF8B5CF6),
                      'Current staking total tokens',
                      isMainMetric: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildReportMetricCard(
                      'Total Rewards',
                      '${_formatNumber(stats.plumeRewards.totalPLUME)} PLUME',
                      Icons.emoji_events,
                      const Color(0xFFFFB800),
                      'Accumulated rewards earned',
                      isMainMetric: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildReportMetricCard(
                      'Staking Streak',
                      '${stats.plumeStakingStreak} days',
                      Icons.local_fire_department,
                      const Color(0xFFFF6B35),
                      'Consecutive staking period',
                      showProgress: true,
                      progressValue: (stats.plumeStakingStreak / 365).clamp(0.0, 1.0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildReportMetricCard(
                      'Referral Bonus PP',
                      '+${stats.referralBonusXp} PP',
                      Icons.card_giftcard,
                      const Color(0xFF06B6D4),
                      'Bonus from referrals',
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildPerformanceSummaryWithErrorHandling(stats),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummaryWithErrorHandling(dynamic stats) {
    try {
      final bool hasPerformanceData = stats != null && 
                                     (stats.totalXp > 0 ||
                                      stats.plumeStaked > 0 ||
                                      stats.dailySpinStreak > 0 ||
                                      stats.completedQuests > 0);

      final performanceStatus = hasPerformanceData ? (
        color: const Color(0xFF10B981), 
        label: 'Active'
      ) : (
        color: const Color(0xFFEF4444),
        label: 'Inactive'
      );

      final double stakingEfficiency = hasPerformanceData ? 
        ((stats.plumeStaked > 0 ? 85.0 : 0.0)) : 0.0;
      final double rewardRate = hasPerformanceData ? 
        ((stats.totalXp > 0 ? 72.0 : 0.0)) : 0.0;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            performanceStatus.color.withValues(alpha: 0.3),
                            performanceStatus.color.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.assessment,
                        color: performanceStatus.color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Performance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: constraints.maxWidth < 300 ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, 
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: performanceStatus.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          performanceStatus.label,
                          style: TextStyle(
                            color: performanceStatus.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 250) {
                  return Column(
                    children: [
                      _buildPerformanceIndicator(
                        'Staking Efficiency',
                        stakingEfficiency,
                        const Color(0xFF10B981),
                        alignment: CrossAxisAlignment.start,
                      ),
                      const SizedBox(height: 16),
                      _buildPerformanceIndicator(
                        'Reward Rate',
                        rewardRate,
                        const Color(0xFFFFB800),
                        alignment: CrossAxisAlignment.start,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildPerformanceIndicator(
                        'Staking Efficiency',
                        stakingEfficiency,
                        const Color(0xFF10B981),
                        alignment: CrossAxisAlignment.start,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPerformanceIndicator(
                        'Reward Rate',
                        rewardRate,
                        const Color(0xFFFFB800),
                        alignment: CrossAxisAlignment.end,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      return _buildPerformanceErrorFallback('Performance status unavailable');
    }
  }

  Widget _buildPerformanceIndicator(
    String title,
    double value,
    Color color,
    {CrossAxisAlignment alignment = CrossAxisAlignment.start}
  ) {
    final bool hasData = value > 0;
    final Color displayColor = hasData ? color : const Color(0xFFEF4444);
    final String displayValue = hasData ? '${value.toStringAsFixed(1)}%' : 'No Data';

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: alignment == CrossAxisAlignment.end
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (alignment == CrossAxisAlignment.end) ...[
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  displayValue,
                  style: TextStyle(
                    color: displayColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: hasData ? [
                    displayColor,
                    displayColor.withValues(alpha: 0.7),
                  ] : [
                    const Color(0xFFEF4444).withValues(alpha: 0.3),
                    const Color(0xFFEF4444).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            if (alignment == CrossAxisAlignment.start) ...[
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  displayValue,
                  style: TextStyle(
                    color: displayColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceErrorFallback(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Performance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @Deprecated('These methods are no longer actively used in static display mode')
  double _calculateStakingEfficiency(dynamic stats) {
    try {
      final stakingTotal = stats?.currentPlumeStakingTotalTokens?.toDouble() ?? 0.0;
      final totalRewards = stats?.plumeRewards?.totalPLUME?.toDouble() ?? 0.0;

      if (stakingTotal <= 0) return 0.0;

      final efficiency = ((totalRewards / stakingTotal) * 100).clamp(0.0, 100.0);
      return efficiency > 100 ? 96.5 : efficiency;
    } catch (e) {
      return 75.0;
    }
  }

  @Deprecated('These methods are no longer actively used in static display mode')
  double _calculateRewardRate(dynamic stats) {
    try {
      final stakingStreak = stats?.plumeStakingStreak?.toInt() ?? 0;
      final rewardBonusXp = stats?.referralBonusXp?.toInt() ?? 0;

      final baseRate = 8.0;
      final streakBonus = (stakingStreak / 30.0).clamp(0.0, 5.0);
      final xpBonus = (rewardBonusXp / 10000.0).clamp(0.0, 2.0);

      return (baseRate + streakBonus + xpBonus).clamp(0.0, 15.0);
    } catch (e) {
      return 10.5;
    }
  }

  @Deprecated('These methods are no longer actively used in static display mode')
  ({Color color, String label}) _getPerformanceStatus(double efficiency, double rewardRate) {
    try {
      final avgPerformance = (efficiency + rewardRate * 5) / 6;

      if (avgPerformance >= 90) {
        return (color: const Color(0xFF10B981), label: 'EXCELLENT');
      } else if (avgPerformance >= 70) {
        return (color: const Color(0xFFFFB800), label: 'GOOD');
      } else if (avgPerformance >= 50) {
        return (color: const Color(0xFFFF6B35), label: 'AVERAGE');
      } else {
        return (color: const Color(0xFFEF4444), label: 'POOR');
      }
    } catch (e) {
      return (color: const Color(0xFF6B7280), label: 'UNKNOWN');
    }
  }

  Widget _buildReportMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String description,
    {bool isMainMetric = false, bool showProgress = false, double progressValue = 0.0}
  ) {
    return Container(
      height: isMainMetric ? 160 : 140,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: isMainMetric ? 0.4 : 0.3),
          width: isMainMetric ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: isMainMetric ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isMainMetric ? 12 : 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: isMainMetric ? 12 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMainMetric ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          if (showProgress) ...[
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progressValue * 100).toInt()}% of yearly goal',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 9,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedActivityCard(dynamic stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1),
                      const Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.timeline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity',
                      style: AppFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Portal blockchain activity summary',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildCompactActivityItem(
                      'Blockchain TX',
                      _isLoadingActivityData 
                          ? 'Loading...'
                          : (_blockchainTxCount?.toString() ?? 'N/A'),
                      Icons.receipt_long,
                      const Color(0xFF10B981),
                      isAsync: _isLoadingActivityData,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactActivityItem(
                      'Total Badges',
                      _isLoadingActivityData 
                          ? 'Loading...'
                          : (_totalBadgeCount?.toString() ?? 'N/A'),
                      Icons.military_tech,
                      const Color(0xFFFFB800),
                      isAsync: _isLoadingActivityData,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildCompactActivityItem(
                      'Protocols',
                      '${stats.protocolsUsed}',
                      Icons.hub,
                      const Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactActivityItem(
                      'Quests',
                      '${stats.completedQuests}',
                      Icons.task_alt,
                      const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildCompactActivityItem(
                      'Spin Streak',
                      '${_getRealDailySpinStreak()}d',
                      Icons.casino,
                      const Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactActivityItem(
                      'Self PP',
                      _formatNumber(stats.userSelfXp.toDouble()),
                      Icons.person_4,
                      const Color(0xFF06B6D4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildTvlMetricsSection(stats),
            ],
          ),

          const SizedBox(height: 20),

          _buildCompactTopActivitiesSection(stats),

          const SizedBox(height: 16),

          _buildCompactTopProtocolUsedSection([
            if (stats.protocol1.isNotEmpty) stats.protocol1,
            if (stats.protocol2.isNotEmpty) stats.protocol2,
            if (stats.protocol3.isNotEmpty) stats.protocol3,
          ]),
        ],
      ),
    );
  }

  Widget _buildActivityMetricItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBattleGroupCard(String battleGroup) {
    final rankChange = _getBattleGroupRankChange();
    final bool hasValidBattleGroup = battleGroup != 'No Battle Group' && battleGroup.isNotEmpty;

    final List<Color> primaryGradient = hasValidBattleGroup 
        ? [const Color(0xFFFF6B35), const Color(0xFFE63946), const Color(0xFFDC2F02)] 
        : [Colors.grey.shade600, Colors.grey.shade500, Colors.grey.shade400];

    final List<Color> backgroundGradient = hasValidBattleGroup 
        ? [const Color(0xFFFF6B35).withValues(alpha: 0.15), 
           const Color(0xFFE63946).withValues(alpha: 0.08), 
           Colors.transparent] 
        : [Colors.white.withValues(alpha: 0.05), 
           Colors.white.withValues(alpha: 0.02), 
           Colors.transparent];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasValidBattleGroup 
              ? const Color(0xFFFF6B35).withValues(alpha: 0.3) 
              : Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasValidBattleGroup 
                ? const Color(0xFFFF6B35).withValues(alpha: 0.1) 
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGradient.first.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  hasValidBattleGroup ? Icons.military_tech_rounded : Icons.help_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Battle Group',
                        style: AppFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        hasValidBattleGroup ? 'Active Combat Unit' : 'Not Assigned',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasValidBattleGroup && rankChange != BattleGroupRankChange.none)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRankChangeColor(rankChange).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getRankChangeColor(rankChange).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRankChangeIcon(rankChange),
                        color: _getRankChangeColor(rankChange),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getRankChangeText(rankChange),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getRankChangeColor(rankChange),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: hasValidBattleGroup 
                        ? const Color(0xFFFF6B35).withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.shield_rounded,
                    color: hasValidBattleGroup 
                        ? const Color(0xFFFF6B35) 
                        : Colors.white.withValues(alpha: 0.6),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),

                Flexible(
                  child: Text(
                    battleGroup,
                    style: TextStyle(
                      fontSize: 16,
                      color: hasValidBattleGroup 
                          ? Colors.white 
                          : Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),

                if (hasValidBattleGroup) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10F993),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10F993).withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankChangeColor(BattleGroupRankChange change) {
    switch (change) {
      case BattleGroupRankChange.up:
        return const Color(0xFF10F993);
      case BattleGroupRankChange.down:
        return const Color(0xFFFF6B6B);
      case BattleGroupRankChange.stable:
        return const Color(0xFFFFB800);
      case BattleGroupRankChange.none:
        return Colors.white70;
    }
  }

  IconData _getRankChangeIcon(BattleGroupRankChange change) {
    switch (change) {
      case BattleGroupRankChange.up:
        return Icons.trending_up;
      case BattleGroupRankChange.down:
        return Icons.trending_down;
      case BattleGroupRankChange.stable:
        return Icons.trending_flat;
      case BattleGroupRankChange.none:
        return Icons.help_outline;
    }
  }

  String _getRankChangeText(BattleGroupRankChange change) {
    switch (change) {
      case BattleGroupRankChange.up:
        return 'UP';
      case BattleGroupRankChange.down:
        return 'DOWN';
      case BattleGroupRankChange.stable:
        return 'STABLE';
      case BattleGroupRankChange.none:
        return '';
    }
  }

  Widget _buildCompactReferralCard(String referralCode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [const Color(0xFF06B6D4).withValues(alpha: 0.3), const Color(0xFF0891B2).withValues(alpha: 0.2)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.share, color: Color(0xFF06B6D4), size: 10),
              ),
              const SizedBox(width: 8),
              FittedBox(fit: BoxFit.scaleDown, child: Text('Referral Code', style: AppFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _copyReferralCodeSilent(referralCode),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(referralCode, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Courier'), maxLines: 1, overflow: TextOverflow.ellipsis))),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: const Color(0xFF06B6D4).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.copy, color: Color(0xFF06B6D4), size: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernLastUpdateInfo() {
    const String donationAddress = '0x3e852c5ef855ae294749eccdf4ae91e371865a40';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Fueled by caffeine. To keep the engine running,',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 9,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  'you can treat me to a coffee here. Thank you, kind folks!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 9,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _copyDonationAddress(donationAddress),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 12,
                      ),
                      const SizedBox(width: 6),

                      Flexible(
                        child: Text(
                          donationAddress,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(width: 6),

                      Icon(
                        Icons.copy,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'For Goon, with love ❤️',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 9,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDailySpinDataWidget() {
    if (_isLoadingDailySpinData) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white70)),
            ),
            const SizedBox(width: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Loading Daily Spin Data...', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
    }
    return _buildDailySpinDataWidget();
  }

  Widget _buildCompactActivityItem(
    String label,
    String value,
    IconData icon,
    Color color,
    {bool isAsync = false}
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: isAsync && value == 'Loading...'
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                        ),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTvlMetricsSection(dynamic stats) {
    final double currentTvl = stats.tvl ?? 0.0;
    final double realTvlUsd = stats.realTvlUsd ?? currentTvl;
    final double historicalTvl = stats.tvlTotalUsd ?? 0.0;
    final double walletTvl = stats.walletTvl?.tvlUsd ?? currentTvl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981),
                    const Color(0xFF059669),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TVL Metrics',
                    style: AppFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Total Value Locked • Live from Portal',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.2),
                    const Color(0xFF059669).withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTvlMetricItem(
                    'Portal TVL',
                    '\$${_formatTvlNumber(currentTvl)}',
                    Icons.trending_up,
                    const Color(0xFF10B981),
                    'Current value shown on Portal UI',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTvlMetricItem(
                    'Market TVL',
                    '\$${_formatTvlNumber(realTvlUsd)}',
                    Icons.verified,
                    const Color(0xFF059669),
                    'Market-adjusted with slippage',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTvlMetricItem(
                    'Historical TVL',
                    '\$${_formatTvlNumber(historicalTvl)}',
                    Icons.history,
                    const Color(0xFF0D9488),
                    'Cumulative historical value',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTvlMetricItem(
                    'Wallet TVL',
                    '\$${_formatTvlNumber(walletTvl)}',
                    Icons.account_balance_wallet,
                    const Color(0xFF14B8A6),
                    'Direct wallet locked value',
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF10B981),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'TVL Data Sources',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Portal TVL: Real-time value from Plume Portal UI\n'
                '• Market TVL: Adjusted for market conditions & fees\n'
                '• Historical TVL: Cumulative total value over time\n'
                '• Wallet TVL: Direct wallet-specific locked assets',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTvlMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 9,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTopActivitiesSection(dynamic stats) {
    List<Map<String, dynamic>> topActivities = _generateTopActivities(stats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_graph,
              color: const Color(0xFF8B5CF6),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Top Activities',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: topActivities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              return Container(
                margin: EdgeInsets.only(right: index < topActivities.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (activity['color'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (activity['color'] as Color).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      activity['icon'],
                      color: activity['color'],
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity['value'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTopProtocolUsedSection(List<String> protocols) {
    if (protocols.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.account_tree,
              color: const Color(0xFF06B6D4),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Top Protocols',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: protocols.take(3).map((protocol) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              protocol,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _generateTopActivities(dynamic stats) {
    List<Map<String, dynamic>> activities = [
      {
        'name': 'Protocol Interactions',
        'value': '${stats.protocolsUsed} protocols',
        'icon': Icons.hub,
        'color': const Color(0xFF6366F1),
        'score': stats.protocolsUsed as int,
      },
      {
        'name': 'Quest Completions',
        'value': '${stats.completedQuests} quests',
        'icon': Icons.task_alt,
        'color': const Color(0xFF8B5CF6),
        'score': stats.completedQuests as int,
      },
      {
        'name': 'Daily Engagement',
        'value': '${_getRealDailySpinStreak()} day streak',
        'icon': Icons.casino,
        'color': const Color(0xFFFF6B35),
        'score': _getRealDailySpinStreak(),
      },
      {
        'name': 'Experience Gained',
        'value': _formatNumber(stats.userSelfXp.toDouble()),
        'icon': Icons.person_4,
        'color': const Color(0xFF06B6D4),
        'score': stats.userSelfXp as int,
      },
    ];

    activities.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return activities.take(4).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
