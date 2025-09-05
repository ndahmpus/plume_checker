import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/plume_portal_models.dart';
import '../models/season1_allocation_models.dart';
import '../utils/app_fonts.dart';
import '../services/plume_api_service.dart';

enum BattleGroupRankChange {
  none,
  up,
  down,
  stable,
}

class Season1Widget extends StatefulWidget {
  final String walletAddress;
  final bool showTitle;
  final int? battleGroup;
  final int? bgRank;

  const Season1Widget({
    super.key,
    required this.walletAddress,
    this.showTitle = true,
    this.battleGroup,
    this.bgRank,
  });

  @override
  State<Season1Widget> createState() => _Season1WidgetState();
}

class _Season1WidgetState extends State<Season1Widget>
    with SingleTickerProviderStateMixin {
  Season1Response? _season1Data;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _previousBattleGroup;
  String? _currentBattleGroup;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _loadSeason1Data();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSeason1Data() async {
    if (widget.walletAddress.isEmpty) return;

    print('🛫 Season1Widget: Loading data for ${widget.walletAddress}');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await PlumeApiService().getSeason1Data(widget.walletAddress);

      print('✅ Season1Widget: Data loaded - $data');

      if (mounted) {
        setState(() {
          _season1Data = data;
          _isLoading = false;
        });

        if (data != null) {
          print('🎯 Season1Widget: Starting animation');
          _animationController.forward();
        }
      }
    } catch (e) {
      print('❌ Season1Widget: Error loading data - $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load Season 1 data';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
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
              if (widget.showTitle) _buildHeader(),
              if (widget.showTitle) const SizedBox(height: 20),

              if (_isLoading)
                _buildLoadingState()
              else if (_errorMessage != null)
                _buildErrorState()
              else if (_season1Data != null && _season1Data!.data.season1Stats.hasData)
                _buildSeason1Content()
              else
                _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981),
                const Color(0xFF059669),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.celebration,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Season 1 Stats',
                style: AppFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Thank you for participating in Plume Testnet',
                  style: TextStyle(
                    fontSize: 11,
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
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 140,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Loading Season 1 data...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 140,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.withValues(alpha: 0.7),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Error loading data',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 140,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Icon(
                Icons.hourglass_empty,
                color: Colors.white.withValues(alpha: 0.6),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Season 1 Data Not Available',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Thank you for participating in Plume Testnet',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeason1Content() {
    final stats = _season1Data!.data.season1Stats;

    if (!stats.hasData) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        if (stats.hasFlightClass) ...[
          _buildFlightClassBadge(stats),
          const SizedBox(height: 20),
        ],

        _buildStatsGrid(stats),

        if (stats.miles > 100) ...[
          const SizedBox(height: 16),
          _buildMilesProgress(stats),
        ],

        const SizedBox(height: 16),
        _buildAllocationButton(),
      ],
    );
  }

  Widget _buildFlightClassBadge(Season1Stats stats) {
    final hasClass = stats.hasFlightClass;
    final classColor = hasClass ? stats.flightClassColor : Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            classColor.withValues(alpha: 0.2),
            classColor.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: classColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            stats.flightClassIcon,
            color: classColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stats.flightClassDisplay,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: classColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stats.flightClassDescription,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Season1Stats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Miles Flown',
            stats.formattedMiles,
            Icons.flight_rounded,
            const Color(0xFF06B6D4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            'Stamps',
            '${stats.stamps}',
            Icons.local_post_office,
            const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            'Referrals',
            '${stats.referrals}',
            Icons.people_outline,
            const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilesProgress(Season1Stats stats) {
    final progress = stats.milesProgress;
    final nextMilestone = stats.nextMilestone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Miles Progress',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Next: ${_formatNumber(nextMilestone)}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  Widget _buildAllocationButton() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showAllocationDialog();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance,
                  color: const Color(0xFF06B6D4),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Check Alokasi Season 1',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.8),
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAllocationDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLoadingBottomSheet(),
    );

    try {
      final allocationResponse = await PlumeApiService().getSeason1AllocationData(widget.walletAddress);

      if (mounted) Navigator.of(context).pop();

      if (allocationResponse != null && mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildAllocationBottomSheet(allocationResponse),
        );
      } else if (mounted) {
        _showErrorDialog('Failed to load Season 1 allocation data');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        _showErrorDialog('Error loading allocation data: $e');
      }
    }
  }

  Widget _buildLoadingBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A0B0F),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 40),

              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Loading Season 1 Allocation...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Please wait while we fetch your allocation data',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllocationBottomSheet(Season1AllocationResponse allocationResponse) {
    final allocation = allocationResponse.data.seasonOneAllocation;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0B0F),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              _buildBottomSheetHeader(allocation),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainAllocationStats(allocation),

                      const SizedBox(height: 20),

                      _buildCompactBattleGroupWidget(allocation),
                      const SizedBox(height: 16),

                      if (allocation.hasAllocation) ...[
                        _buildAllocationProgress(allocation),
                        const SizedBox(height: 20),
                      ],

                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetHeader(Season1Allocation allocation) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF06B6D4).withValues(alpha: 0.2),
            const Color(0xFF0891B2).withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          if (allocation.allocationStatus == 'estimated') ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: const Color(0xFF8B5CF6),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Estimated allocation based on your wallet activity',
                      style: TextStyle(
                        color: const Color(0xFF8B5CF6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF06B6D4),
                      Color(0xFF0891B2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                      '🏆 Season 1 Allocation',
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: allocation.totalAllocation > 0 
                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                : Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: allocation.totalAllocation > 0 
                                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                  : Colors.red.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                allocation.totalAllocation > 0 
                                    ? Icons.verified_user 
                                    : Icons.cancel,
                                color: allocation.totalAllocation > 0 
                                    ? const Color(0xFF10B981)
                                    : Colors.red,
                                size: 10,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                allocation.totalAllocation > 0 ? '✅ Eligible' : '❌ Not Eligible',
                                style: TextStyle(
                                  color: allocation.totalAllocation > 0 
                                      ? const Color(0xFF10B981)
                                      : Colors.red,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: allocation.claimPercentage >= 100 
                                ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                                : const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: allocation.claimPercentage >= 100 
                                  ? const Color(0xFFFFD700).withValues(alpha: 0.4)
                                  : const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                allocation.claimPercentage >= 100 
                                    ? Icons.check_circle
                                    : Icons.hourglass_empty,
                                color: allocation.claimPercentage >= 100 
                                    ? const Color(0xFFFFD700)
                                    : const Color(0xFF8B5CF6),
                                size: 10,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                allocation.claimPercentage >= 100 ? '🏆 Full Claimed' : '⏳ Waiting',
                                style: TextStyle(
                                  color: allocation.claimPercentage >= 100 
                                      ? const Color(0xFFFFD700)
                                      : const Color(0xFF8B5CF6),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainAllocationStats(Season1Allocation allocation) {
    if (allocation.allocationStatus == 'not_available' || allocation.allocationStatus == 'none') {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Season 1 Allocation Not Available',
                    style: AppFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This wallet may not be eligible for Season 1 allocation, or the allocation program has not started yet.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: const Color(0xFF8B5CF6),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Allocation Breakdown',
                style: AppFonts.orbitron(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildAllocationBreakdownItem(
                  '🏛️ Base Allocation',
                  _getBaseAllocation(allocation),
                  const Color(0xFF06B6D4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAllocationBreakdownItem(
                  '🚀 PLUME Boost',
                  _getPlumeBoost(allocation),
                  const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF06B6D4).withValues(alpha: 0.1),
                  const Color(0xFF0891B2).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: const Color(0xFF06B6D4),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Total Allocation',
                  style: AppFonts.orbitron(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  allocation.formattedTotalAllocation,
                  style: AppFonts.orbitron(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF06B6D4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: const Color(0xFF10B981),
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Claimed',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              allocation.formattedClaimedAmount,
                              style: TextStyle(
                                color: const Color(0xFF10B981),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        color: const Color(0xFF06B6D4),
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Remaining',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              allocation.formattedRemainingAmount,
                              style: TextStyle(
                                color: const Color(0xFF06B6D4),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationBreakdownItem(String title, String value, Color color) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: AppFonts.orbitron(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getBaseAllocation(Season1Allocation allocation) {
    for (final detail in allocation.allocationDetails) {
      if (detail.category.toLowerCase().contains('base')) {
        return _formatAllocationValue(detail.amount);
      }
    }
    double baseAmount = allocation.totalAllocation * 0.7;
    return _formatAllocationValue(baseAmount);
  }

  String _getPlumeBoost(Season1Allocation allocation) {
    for (final detail in allocation.allocationDetails) {
      if (detail.category.toLowerCase().contains('boost') || 
          detail.category.toLowerCase().contains('plume')) {
        return _formatAllocationValue(detail.amount);
      }
    }
    double boostAmount = allocation.totalAllocation * 0.3;
    return _formatAllocationValue(boostAmount);
  }

  String _formatAllocationValue(double amount) {
    if (amount == 0) return '0';
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else if (amount >= 1) {
      return '${amount.toStringAsFixed(0)}';
    } else {
      return '${amount.toStringAsFixed(2)}';
    }
  }

  Widget _buildAllocationStatItem(String label, String amount, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: AppFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationProgress(Season1Allocation allocation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.trending_up,
                color: const Color(0xFF10B981),
                size: 12,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '📈 Claiming Progress',
              style: AppFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: allocation.claimPercentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF10B981),
                        Color(0xFF059669),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${allocation.formattedClaimPercentage} Claimed',
              style: TextStyle(
                color: const Color(0xFF10B981),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${allocation.formattedRemainingPercentage} Remaining',
              style: TextStyle(
                color: const Color(0xFF06B6D4),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPoolStatistics(AllocationStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pool Statistics',
            style: AppFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildPoolStat(
                  'Total Pool',
                  stats.formattedTotalPool,
                  Icons.account_balance,
                  const Color(0xFF06B6D4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPoolStat(
                  'Eligible Users',
                  stats.formattedTotalUsers,
                  Icons.people,
                  const Color(0xFF06B6D4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildPoolStat(
            'Average Allocation',
            stats.formattedAverageAllocation,
            Icons.analytics,
            const Color(0xFF8B5CF6),
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.timeline,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Phase: ${stats.distributionPhase}',
                  style: TextStyle(
                    color: const Color(0xFF10B981),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoolStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Error',
              style: AppFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: const Color(0xFF06B6D4),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981);
      case 'claimed':
        return const Color(0xFF06B6D4);
      case 'expired':
        return Colors.orange;
      case 'pending':
        return const Color(0xFF8B5CF6);
      case 'not_available':
      case 'none':
        return Colors.orange;
      case 'estimated':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'diamond':
        return const Color(0xFF60A5FA);
      case 'platinum':
        return const Color(0xFFE5E7EB);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }

  IconData _getTierIcon(String tier) {
    switch (tier.toLowerCase()) {
      case 'diamond':
        return Icons.diamond;
      case 'platinum':
      case 'gold':
      case 'silver':
      case 'bronze':
        return Icons.military_tech;
      default:
        return Icons.card_membership;
    }
  }

  Widget _buildCompactBattleGroupWidget(Season1Allocation allocation) {
    String battleGroup = 'No Battle Group';

    battleGroup = _getBattleGroupFromAPI();

    if (battleGroup == 'No Battle Group' && allocation.hasAllocation && allocation.eligibilityTier.isNotEmpty) {
      switch (allocation.eligibilityTier.toLowerCase()) {
        case 'diamond':
          battleGroup = 'Alpha Squadron';
          break;
        case 'platinum':
          battleGroup = 'Beta Squadron';
          break;
        case 'gold':
          battleGroup = 'Gamma Squadron';
          break;
        case 'silver':
          battleGroup = 'Delta Squadron';
          break;
        case 'bronze':
          battleGroup = 'Echo Squadron';
          break;
        default:
          battleGroup = 'Training Unit';
      }
    }

    final rankChange = _getBattleGroupRankChange();
    final bool hasValidBattleGroup = battleGroup != 'No Battle Group' && battleGroup.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValidBattleGroup 
              ? const Color(0xFFFF6B35).withValues(alpha: 0.2) 
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.shield_rounded,
                  color: const Color(0xFFFF6B35),
                  size: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Battle Group',
                style: AppFonts.orbitron(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (hasValidBattleGroup && rankChange != BattleGroupRankChange.none)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRankChangeColor(rankChange).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getRankChangeColor(rankChange).withValues(alpha: 0.4),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRankChangeIcon(rankChange),
                        color: _getRankChangeColor(rankChange),
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _getRankChangeText(rankChange),
                        style: TextStyle(
                          fontSize: 8,
                          color: _getRankChangeColor(rankChange),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.military_tech_rounded,
                  color: hasValidBattleGroup 
                      ? const Color(0xFFFF6B35) 
                      : Colors.white.withValues(alpha: 0.6),
                  size: 14,
                ),
                const SizedBox(width: 8),

                Flexible(
                  child: Text(
                    battleGroup,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasValidBattleGroup 
                          ? Colors.white 
                          : Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),

                if (hasValidBattleGroup) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10F993),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10F993).withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 0.5,
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

  BattleGroupRankChange _getBattleGroupRankChange() {

    if (widget.battleGroup == null || widget.battleGroup! <= 0) {
      return BattleGroupRankChange.none;
    }

    final currentBg = widget.battleGroup!;
    final currentRank = widget.bgRank;

    if (currentRank != null && currentRank > 0) {
      if (currentRank <= 10) {
        return BattleGroupRankChange.up;
      } else if (currentRank <= 50) {
        return BattleGroupRankChange.stable;
      } else {
        return BattleGroupRankChange.down;
      }
    }

    return BattleGroupRankChange.none;
  }

  int? _extractRankFromBattleGroup(String battleGroup) {
    final RegExp battleGroupRegex = RegExp(r'Battle Group (\d+)');
    final match = battleGroupRegex.firstMatch(battleGroup);

    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    final RegExp numberRegex = RegExp(r'\d+');
    final numberMatch = numberRegex.firstMatch(battleGroup);

    if (numberMatch != null) {
      return int.tryParse(numberMatch.group(0)!);
    }

    return null;
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

  String _getBattleGroupFromAPI() {
    print('🛡️ Season1Widget: Battle Group Data:');
    print('   battleGroup: ${widget.battleGroup}');
    print('   bgRank: ${widget.bgRank}');

    if (widget.battleGroup != null && widget.battleGroup! > 0) {
      final bgNumber = widget.battleGroup!;
      final bgRank = widget.bgRank;

      String result = 'Battle Group $bgNumber';
      if (bgRank != null && bgRank > 0) {
        result += ' (Rank #$bgRank)';
      }

      print('   📋 Formatted result: $result');
      return result;
    }

    print('   ❌ No valid battle group data - returning fallback');
    return 'No Battle Group';
  }
}
