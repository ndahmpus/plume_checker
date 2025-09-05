import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/services.dart';
import '../models/plume_portal_models.dart';
import '../services/plume_api_service.dart';
import '../utils/app_fonts.dart';

class PlumeBadgesWidget extends StatefulWidget {
  final String walletAddress;
  final bool showTitle;
  final int maxBadgesToShow;

  const PlumeBadgesWidget({
    super.key,
    required this.walletAddress,
    this.showTitle = true,
    this.maxBadgesToShow = 12,
  });

  @override
  State<PlumeBadgesWidget> createState() => _PlumeBadgesWidgetState();
}

class _PlumeBadgesWidgetState extends State<PlumeBadgesWidget> {
  BadgesResponse? _badgesResponse;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final badgesResponse = await PlumeApiService().getBadges(widget.walletAddress);

      if (mounted) {
        setState(() {
          _badgesResponse = badgesResponse;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load badges: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshBadges() async {
    HapticFeedback.lightImpact();
    try {
      final badgesResponse = await PlumeApiService().refreshBadges(widget.walletAddress);

      if (mounted) {
        setState(() {
          _badgesResponse = badgesResponse;
          _error = null;
        });

        if (badgesResponse != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🏅 Badges refreshed'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Refresh failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _badgesResponse == null) {
      return _buildLoadingWidget();
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_badgesResponse == null) {
      return const SizedBox.shrink();
    }

    return _buildBadgesContent();
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            strokeWidth: 2,
          ),
          SizedBox(height: 12),
          Text(
            'Loading badges...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.orange,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to load badges',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadBadges,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesContent() {
    final badgesData = _badgesResponse!.data;
    final earnedBadges = badgesData.earnedBadges;
    final availableBadges = badgesData.availableBadges;

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
          if (widget.showTitle) _buildHeader(badgesData),

          _buildSummaryStats(badgesData),
          const SizedBox(height: 20),

          if (earnedBadges.isNotEmpty) ...[
            _buildSectionHeader('Earned Badges', earnedBadges.length, Icons.check_circle, Colors.green),
            const SizedBox(height: 12),
            _buildBadgesGrid(earnedBadges.take(widget.maxBadgesToShow ~/ 2).toList(), true),
            if (earnedBadges.length > widget.maxBadgesToShow ~/ 2) ...[
              const SizedBox(height: 8),
              _buildShowMoreButton(earnedBadges.length - (widget.maxBadgesToShow ~/ 2), true),
            ],
            const SizedBox(height: 20),
          ],

          if (availableBadges.isNotEmpty) ...[
            _buildSectionHeader('Available Badges', availableBadges.length, Icons.outlined_flag, Colors.white60),
            const SizedBox(height: 12),
            _buildBadgesGrid(availableBadges.take(widget.maxBadgesToShow ~/ 2).toList(), false),
            if (availableBadges.length > widget.maxBadgesToShow ~/ 2) ...[
              const SizedBox(height: 8),
              _buildShowMoreButton(availableBadges.length - (widget.maxBadgesToShow ~/ 2), false),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BadgesData badgesData) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFB800),
                const Color(0xFFFF8C00),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB800).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.military_tech, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Badges & Achievements',
                style: AppFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Your accomplishments in the Plume ecosystem',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(BadgesData badgesData) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryStatItem(
            'Total',
            '${badgesData.badges.length}',
            Icons.apps,
            const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryStatItem(
            'Earned',
            '${badgesData.earnedBadges.length}',
            Icons.check_circle,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryStatItem(
            'Points',
            '${badgesData.totalPlumePoints}',
            Icons.diamond,
            const Color(0xFFFFB800),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          '$title ($count)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesGrid(List<Badge> badges, bool isEarned) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges.map((badge) => _buildBadgeItem(badge, isEarned)).toList(),
    );
  }

  Widget _buildBadgeItem(Badge badge, bool isEarned) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(badge),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEarned 
              ? badge.categoryColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEarned 
                ? badge.categoryColor.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.2),
            width: isEarned ? 1.5 : 1,
          ),
          boxShadow: isEarned ? [
            BoxShadow(
              color: badge.categoryColor.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isEarned 
                        ? badge.categoryColor.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isEarned 
                          ? badge.categoryColor.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    badge.categoryIcon,
                    size: 16,
                    color: isEarned ? badge.categoryColor : Colors.white60,
                  ),
                ),
                if (isEarned)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              badge.title,
              style: TextStyle(
                color: isEarned ? Colors.white : Colors.white60,
                fontSize: 9,
                fontWeight: isEarned ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (badge.hasPoints && isEarned) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${badge.pp} PP',
                  style: const TextStyle(
                    color: Color(0xFFFFB800),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShowMoreButton(int remainingCount, bool isEarned) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _showAllBadges(isEarned),
        icon: Icon(
          Icons.expand_more,
          size: 16,
          color: Colors.white70,
        ),
        label: Text(
          '+$remainingCount more',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ),
      ),
    );
  }

  void _showBadgeDetails(Badge badge) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: badge.categoryColor.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: badge.categoryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: badge.categoryColor.withValues(alpha: 0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: badge.categoryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  badge.categoryIcon,
                  size: 40,
                  color: badge.categoryColor,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                badge.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badge.isEarned 
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: badge.isEarned 
                        ? Colors.green.withValues(alpha: 0.4)
                        : Colors.orange.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      badge.isEarned ? Icons.check_circle : Icons.lock_outline,
                      size: 16,
                      color: badge.isEarned ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badge.isEarned ? 'Earned' : 'Not Earned',
                      style: TextStyle(
                        color: badge.isEarned ? Colors.green : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (badge.description.isNotEmpty) ...[
                Text(
                  badge.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              if (badge.hasPoints) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB800).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFB800).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.diamond,
                        size: 18,
                        color: Color(0xFFFFB800),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${badge.pp} Plume Points',
                        style: const TextStyle(
                          color: Color(0xFFFFB800),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: badge.categoryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllBadges(bool isEarned) {
    final badgesData = _badgesResponse!.data;
    final badges = isEarned ? badgesData.earnedBadges : badgesData.availableBadges;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    isEarned ? Icons.check_circle : Icons.outlined_flag,
                    color: isEarned ? Colors.green : Colors.white60,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEarned ? 'All Earned Badges' : 'All Available Badges',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: badges.map((badge) => _buildBadgeItem(badge, isEarned)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BadgesData badgesData) {
    final categories = BadgeCategory.values;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final badges = badgesData.badges.where((badge) => badge.category == category).toList();
          if (badges.isEmpty) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                _getCategoryName(category),
                style: const TextStyle(fontSize: 12),
              ),
              avatar: Icon(
                _getCategoryIcon(category),
                size: 16,
              ),
              onSelected: (selected) {
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryName(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.quest:
        return 'Quests';
      case BadgeCategory.role:
        return 'Roles';
      case BadgeCategory.guardian:
        return 'Guardian';
      case BadgeCategory.event:
        return 'Events';
      case BadgeCategory.protocol:
        return 'Protocol';
      case BadgeCategory.other:
        return 'Other';
    }
  }

  IconData _getCategoryIcon(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.quest:
        return Icons.assignment_turned_in;
      case BadgeCategory.role:
        return Icons.badge;
      case BadgeCategory.guardian:
        return Icons.shield;
      case BadgeCategory.event:
        return Icons.celebration;
      case BadgeCategory.protocol:
        return Icons.hub;
      case BadgeCategory.other:
        return Icons.star;
    }
  }
}
