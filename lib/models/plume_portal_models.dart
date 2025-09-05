import 'package:flutter/material.dart';

class PortalWalletStatsResponse {
  final PortalWalletData data;

  PortalWalletStatsResponse({required this.data});

  factory PortalWalletStatsResponse.fromJson(Map<String, dynamic> json) {
    return PortalWalletStatsResponse(
      data: PortalWalletData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
    };
  }
}

class PortalWalletData {
  final String walletAddress;
  final PortalWalletStats stats;
  final WalletContext walletContext;

  PortalWalletData({
    required this.walletAddress,
    required this.stats,
    required this.walletContext,
  });

  factory PortalWalletData.fromJson(Map<String, dynamic> json) {
    return PortalWalletData(
      walletAddress: json['walletAddress'] ?? '',
      stats: PortalWalletStats.fromJson(json['stats'] ?? {}),
      walletContext: WalletContext.fromJson(json['walletContext'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletAddress': walletAddress,
      'stats': stats.toJson(),
      'walletContext': walletContext.toJson(),
    };
  }
}

class PortalWalletStats {
  final String walletAddress;

  final double bridgedTotal;
  final double swapVolume;
  final int swapCount;
  final double tvlTotalUsd;
  final double tvl;
  final double realTvlUsd;

  final int totalXp;
  final int userSelfXp;
  final int referralBonusXp;
  final int xpRank;

  final int protocolsUsed;
  final int completedQuests;
  final int dailySpinStreak;
  final int longestSwapStreakWeeks;
  final int longestTvlStreak;

  final double plumeStaked;
  final int plumeStakingStreak;
  final int plumeStakingLongestStreakDays;
  final double currentPlumeStakingTotalTokens;
  final PlumeStakingClaimedAmount plumeStakingClaimedAmount;
  final int plumeStakingPointsEarned;
  final int plumeStakingBonusPointsEarned;

  final int adjustmentPoints;
  final int protectorsOfPlumePoints;
  final int badgePoints;

  final PlumeRewards plumeRewards;

  final int referrals;
  final int referralCount;
  final String? referredBy;
  final String referralCode;
  final PortalUser? referredByUser;

  final String protocol1;
  final int daysUsed1;
  final String protocol2;
  final int daysUsed2;
  final String protocol3;
  final int daysUsed3;

  final int? battleGroup;
  final int? bgRank;

  final String dateStr;
  final String currentTvlLevels;
  final bool everActiveSnapshot;
  final WalletTvl walletTvl;
  final PortalUser user;

  PortalWalletStats({
    required this.walletAddress,
    required this.bridgedTotal,
    required this.swapVolume,
    required this.swapCount,
    required this.tvlTotalUsd,
    required this.tvl,
    required this.realTvlUsd,
    required this.totalXp,
    required this.userSelfXp,
    required this.referralBonusXp,
    required this.xpRank,
    required this.protocolsUsed,
    required this.completedQuests,
    required this.dailySpinStreak,
    required this.longestSwapStreakWeeks,
    required this.longestTvlStreak,
    required this.plumeStaked,
    required this.plumeStakingStreak,
    required this.plumeStakingLongestStreakDays,
    required this.currentPlumeStakingTotalTokens,
    required this.plumeStakingClaimedAmount,
    required this.plumeStakingPointsEarned,
    required this.plumeStakingBonusPointsEarned,
    required this.adjustmentPoints,
    required this.protectorsOfPlumePoints,
    required this.badgePoints,
    required this.plumeRewards,
    required this.referrals,
    required this.referralCount,
    this.referredBy,
    required this.referralCode,
    this.referredByUser,
    required this.protocol1,
    required this.daysUsed1,
    required this.protocol2,
    required this.daysUsed2,
    required this.protocol3,
    required this.daysUsed3,
    this.battleGroup,
    this.bgRank,
    required this.dateStr,
    required this.currentTvlLevels,
    required this.everActiveSnapshot,
    required this.walletTvl,
    required this.user,
  });

  factory PortalWalletStats.fromJson(Map<String, dynamic> json) {
    return PortalWalletStats(
      walletAddress: json['walletAddress'] ?? '',
      bridgedTotal: _parseDouble(json['bridgedTotal']),
      swapVolume: _parseDouble(json['swapVolume']),
      swapCount: json['swapCount'] ?? 0,
      tvlTotalUsd: _parseDouble(json['tvlTotalUsd']),
      tvl: _parseDouble(json['TVL']),
      realTvlUsd: _parseDouble(json['realTvlUsd']),
      totalXp: json['totalXp'] ?? 0,
      userSelfXp: json['userSelfXp'] ?? 0,
      referralBonusXp: json['referralBonusXp'] ?? 0,
      xpRank: json['xpRank'] ?? 0,
      protocolsUsed: json['protocolsUsed'] ?? 0,
      completedQuests: json['completedQuests'] ?? 0,
      dailySpinStreak: json['dailySpinStreak'] ?? 0,
      longestSwapStreakWeeks: json['longestSwapStreakWeeks'] ?? 0,
      longestTvlStreak: json['longestTvlStreak'] ?? 0,
      plumeStaked: _parseDouble(json['plumeStaked']),
      plumeStakingStreak: json['plumeStakingStreak'] ?? 0,
      plumeStakingLongestStreakDays: json['plumeStakingLongestStreakDays'] ?? 0,
      currentPlumeStakingTotalTokens: _parseDouble(json['currentPlumeStakingTotalTokens']),
      plumeStakingClaimedAmount: PlumeStakingClaimedAmount.fromJson(json['plumeStakingClaimedAmount'] ?? {}),
      plumeStakingPointsEarned: json['plumeStakingPointsEarned'] ?? 0,
      plumeStakingBonusPointsEarned: json['plumeStakingBonusPointsEarned'] ?? 0,
      adjustmentPoints: json['adjustmentPoints'] ?? 0,
      protectorsOfPlumePoints: json['protectorsOfPlumePoints'] ?? 0,
      badgePoints: json['badgePoints'] ?? 0,
      plumeRewards: PlumeRewards.fromJson(json['plumeRewards'] ?? {}),
      referrals: json['referrals'] ?? 0,
      referralCount: json['referralCount'] ?? 0,
      referredBy: json['referredBy'],
      referralCode: json['referralCode'] ?? '',
      referredByUser: json['referredByUser'] != null ? PortalUser.fromJson(json['referredByUser']) : null,
      protocol1: json['protocol1'] ?? '',
      daysUsed1: json['daysUsed1'] ?? 0,
      protocol2: json['protocol2'] ?? '',
      daysUsed2: json['daysUsed2'] ?? 0,
      protocol3: json['protocol3'] ?? '',
      daysUsed3: json['daysUsed3'] ?? 0,
      battleGroup: json['battleGroup'],
      bgRank: json['bgRank'],
      dateStr: json['dateStr'] ?? '',
      currentTvlLevels: json['currentTvlLevels'] ?? '',
      everActiveSnapshot: json['everActiveSnapshot'] ?? false,
      walletTvl: WalletTvl.fromJson(json['walletTvl'] ?? {}),
      user: PortalUser.fromJson(json['user'] ?? {}),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'walletAddress': walletAddress,
      'bridgedTotal': bridgedTotal,
      'swapVolume': swapVolume,
      'swapCount': swapCount,
      'tvlTotalUsd': tvlTotalUsd,
      'TVL': tvl,
      'realTvlUsd': realTvlUsd,
      'totalXp': totalXp,
      'userSelfXp': userSelfXp,
      'referralBonusXp': referralBonusXp,
      'xpRank': xpRank,
      'protocolsUsed': protocolsUsed,
      'completedQuests': completedQuests,
      'dailySpinStreak': dailySpinStreak,
      'longestSwapStreakWeeks': longestSwapStreakWeeks,
      'longestTvlStreak': longestTvlStreak,
      'plumeStaked': plumeStaked,
      'plumeStakingStreak': plumeStakingStreak,
      'plumeStakingLongestStreakDays': plumeStakingLongestStreakDays,
      'currentPlumeStakingTotalTokens': currentPlumeStakingTotalTokens,
      'plumeStakingClaimedAmount': plumeStakingClaimedAmount.toJson(),
      'plumeStakingPointsEarned': plumeStakingPointsEarned,
      'plumeStakingBonusPointsEarned': plumeStakingBonusPointsEarned,
      'adjustmentPoints': adjustmentPoints,
      'protectorsOfPlumePoints': protectorsOfPlumePoints,
      'badgePoints': badgePoints,
      'plumeRewards': plumeRewards.toJson(),
      'referrals': referrals,
      'referralCount': referralCount,
      'referredBy': referredBy,
      'referralCode': referralCode,
      'referredByUser': referredByUser?.toJson(),
      'protocol1': protocol1,
      'daysUsed1': daysUsed1,
      'protocol2': protocol2,
      'daysUsed2': daysUsed2,
      'protocol3': protocol3,
      'daysUsed3': daysUsed3,
      'battleGroup': battleGroup,
      'bgRank': bgRank,
      'dateStr': dateStr,
      'currentTvlLevels': currentTvlLevels,
      'everActiveSnapshot': everActiveSnapshot,
      'walletTvl': walletTvl.toJson(),
      'user': user.toJson(),
    };
  }

  String get formattedBridgedTotal => '\$${bridgedTotal.toStringAsFixed(2)}';
  String get formattedSwapVolume => '\$${swapVolume.toStringAsFixed(2)}';
  String get formattedTvl => '\$${tvl.toStringAsFixed(2)}';
  String get formattedRealTvlUsd => '\$${realTvlUsd.toStringAsFixed(2)}';
  String get formattedTotalXp => totalXp.toString();
  String get formattedXpRank => '#${xpRank.toString()}';
  String get formattedPlumeStaked => '${plumeStaked.toStringAsFixed(3)} PLUME';

  String get totalReferrals => referralCount.toString();

  List<ProtocolUsage> get topProtocols {
    final protocols = <ProtocolUsage>[
      ProtocolUsage(name: protocol1, daysUsed: daysUsed1),
      ProtocolUsage(name: protocol2, daysUsed: daysUsed2),
      ProtocolUsage(name: protocol3, daysUsed: daysUsed3),
    ];

    protocols.sort((a, b) => b.daysUsed.compareTo(a.daysUsed));
    return protocols.where((p) => p.name.isNotEmpty).toList();
  }

  String get activityLevel {
    final score = (completedQuests * 10) + 
                  (dailySpinStreak * 5) + 
                  (protocolsUsed * 20) + 
                  (swapCount ~/ 10);

    if (score >= 200) return 'Very Active';
    if (score >= 100) return 'Active';
    if (score >= 50) return 'Moderate';
    return 'Low';
  }

  String activityLevelWithRealStreak(List<SpinRecord> dailySpinRecords) {
    final realStreak = calculateRealCurrentStreak(dailySpinRecords);
    final score = (completedQuests * 10) + 
                  (realStreak * 5) + 
                  (protocolsUsed * 20) + 
                  (swapCount ~/ 10);

    if (score >= 200) return 'Very Active';
    if (score >= 100) return 'Active';
    if (score >= 50) return 'Moderate';
    return 'Low';
  }

  static int calculateRealCurrentStreak(List<SpinRecord> spinRecords, {bool enableDebug = false}) {
    if (enableDebug) {
      print('\n🔥 PortalWalletStats.calculateRealCurrentStreak() called');
      print('   🎯 ACTIVE STREAK LOGIC: Must be recent and consecutive from today');
      print('   📊 Spin records count: ${spinRecords.length}');
      print('   🐛 Debug mode: ENABLED');
    }

    if (spinRecords.isEmpty) {
      if (enableDebug) print('   ❌ No spin records - returning 0');
      return 0;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (enableDebug) {
      print('   📅 Today: ${today.toString().split(' ')[0]}');
      print('   📅 Yesterday: ${yesterday.toString().split(' ')[0]}');
    }

    final Set<DateTime> spinDates = <DateTime>{};
    int validRecords = 0;
    int invalidRecords = 0;
    DateTime? mostRecentSpinDate;

    if (enableDebug) {
      print('   🔍 Processing spin records...');
    }

    for (final record in spinRecords) {
      final recordDateTime = record.dateTime;
      if (recordDateTime != null) {
        final dateOnly = DateTime(recordDateTime.year, recordDateTime.month, recordDateTime.day);
        spinDates.add(dateOnly);

        if (mostRecentSpinDate == null || dateOnly.isAfter(mostRecentSpinDate)) {
          mostRecentSpinDate = dateOnly;
        }

        validRecords++;
        if (enableDebug) {
          print('   ✅ Valid: ${dateOnly.toString().split(' ')[0]} (ID: ${record.id})');
        }
      } else {
        invalidRecords++;
        if (enableDebug) {
          print('   ❌ Invalid: ID ${record.id}, dateStr: "${record.dateStr}"');
        }
      }
    }

    if (enableDebug) {
      print('   📈 Validation summary:');
      print('     ✅ Valid records: $validRecords');
      print('     ❌ Invalid records: $invalidRecords');
      print('     📅 Unique spin dates: ${spinDates.length}');
      if (mostRecentSpinDate != null) {
        final daysSinceLastSpin = today.difference(mostRecentSpinDate).inDays;
        print('     🕒 Most recent spin: ${mostRecentSpinDate.toString().split(' ')[0]}');
        print('     ⏱️ Days since last spin: $daysSinceLastSpin days');
      }
    }

    if (spinDates.isEmpty) {
      if (enableDebug) print('   ❌ No valid dates found - returning 0');
      return 0;
    }

    final hasSpinToday = spinDates.contains(today);
    final hasSpinYesterday = spinDates.contains(yesterday);

    if (enableDebug) {
      print('   🔍 ACTIVE STREAK CHECK:');
      print('     📅 Has spin today (${today.toString().split(' ')[0]}): $hasSpinToday');
      print('     📅 Has spin yesterday (${yesterday.toString().split(' ')[0]}): $hasSpinYesterday');
    }

    if (!hasSpinToday && !hasSpinYesterday) {
      if (enableDebug) {
        final daysSinceLastSpin = mostRecentSpinDate != null ? today.difference(mostRecentSpinDate).inDays : 999;
        print('   🚫 STREAK INACTIVE: No spin today or yesterday');
        print('   ⏱️ Last spin was $daysSinceLastSpin days ago - TOO OLD');
        print('   ✨ ACTIVE STREAK RESULT: 0 days (inactive)');
        print('   🎯 Calculation completed successfully\n');
      }
      return 0;
    }

    DateTime startDate = hasSpinToday ? today : yesterday;

    if (enableDebug) {
      print('   🎯 ACTIVE streak detected - starting from: ${startDate.toString().split(' ')[0]}');
      print('   🔄 Counting consecutive days backwards...');
    }

    int streak = 0;
    DateTime currentCheckDate = startDate;

    while (spinDates.contains(currentCheckDate)) {
      streak++;

      if (enableDebug) {
        final dayOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][currentCheckDate.weekday - 1];
        print('   📅 Day $streak: ${currentCheckDate.toString().split(' ')[0]} ($dayOfWeek) ✅ HAS SPIN');
      }

      currentCheckDate = currentCheckDate.subtract(const Duration(days: 1));

      if (startDate.difference(currentCheckDate).inDays >= 365) {
        if (enableDebug) {
          print('   ⚠️ Safety limit: Stopped at 365 days');
        }
        break;
      }
    }

    if (enableDebug) {
      if (streak > 0) {
        final breakDate = currentCheckDate;
        final dayOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][breakDate.weekday - 1];
        print('   🚫 STREAK BREAKS at: ${breakDate.toString().split(' ')[0]} ($dayOfWeek) - NO SPIN');
        print('   🏁 Final consecutive streak: $streak days');
      } else {
        print('   🏁 Final consecutive streak: $streak days');
      }
      print('   ✨ ACTIVE CONSECUTIVE STREAK RESULT: $streak days');
      print('   🎯 Calculation completed successfully\n');
    }

    return streak;
  }

  String get defiEngagement {
    if (swapCount >= 100 && tvl >= 100) return 'DeFi Power User';
    if (swapCount >= 50 && tvl >= 50) return 'DeFi Enthusiast';
    if (swapCount >= 20 || tvl >= 20) return 'DeFi Explorer';
    return 'DeFi Newcomer';
  }

  String get stakingCommitment {
    if (plumeStakingStreak >= 60 && plumeStaked >= 200) return 'Diamond Hands';
    if (plumeStakingStreak >= 30 && plumeStaked >= 100) return 'Strong Believer';
    if (plumeStakingStreak >= 14 && plumeStaked >= 50) return 'Committed Staker';
    if (plumeStaked > 0) return 'New Staker';
    return 'Not Staking';
  }
}

class PlumeStakingClaimedAmount {
  final double plume;
  final double usdc;

  PlumeStakingClaimedAmount({
    required this.plume,
    required this.usdc,
  });

  factory PlumeStakingClaimedAmount.fromJson(Map<String, dynamic> json) {
    return PlumeStakingClaimedAmount(
      plume: PortalWalletStats._parseDouble(json['plume']),
      usdc: PortalWalletStats._parseDouble(json['usdc']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plume': plume,
      'usdc': usdc,
    };
  }

  String get formattedPlume => '${plume.toStringAsFixed(6)} PLUME';
  String get formattedUsdc => '${usdc.toStringAsFixed(2)} USDC';
  double get totalClaimedUsd => (plume * 1.0) + usdc;
}

class PlumeRewards {
  final BigInt spin;
  final BigInt staking;
  final BigInt royco;
  final BigInt merkl;

  PlumeRewards({
    required this.spin,
    required this.staking,
    required this.royco,
    required this.merkl,
  });

  factory PlumeRewards.fromJson(Map<String, dynamic> json) {
    return PlumeRewards(
      spin: BigInt.tryParse(json['spin']?.toString() ?? '0') ?? BigInt.zero,
      staking: BigInt.tryParse(json['staking']?.toString() ?? '0') ?? BigInt.zero,
      royco: BigInt.tryParse(json['royco']?.toString() ?? '0') ?? BigInt.zero,
      merkl: BigInt.tryParse(json['merkl']?.toString() ?? '0') ?? BigInt.zero,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spin': spin.toString(),
      'staking': staking.toString(),
      'royco': royco.toString(),
      'merkl': merkl.toString(),
    };
  }

  double get spinPLUME => spin.toDouble() / 1e18;
  double get stakingPLUME => staking.toDouble() / 1e18;
  double get roycoPLUME => royco.toDouble() / 1e18;
  double get merklPLUME => merkl.toDouble() / 1e18;

  double get totalPLUME => spinPLUME + stakingPLUME + roycoPLUME + merklPLUME;

  String get formattedSpinRewards => '${spinPLUME.toStringAsFixed(3)} PLUME';
  String get formattedStakingRewards => '${stakingPLUME.toStringAsFixed(3)} PLUME';
  String get formattedTotalRewards => '${totalPLUME.toStringAsFixed(3)} PLUME';
}

class WalletTvl {
  final String walletAddress;
  final double tvlUsd;

  WalletTvl({
    required this.walletAddress,
    required this.tvlUsd,
  });

  factory WalletTvl.fromJson(Map<String, dynamic> json) {
    return WalletTvl(
      walletAddress: json['walletAddress'] ?? '',
      tvlUsd: PortalWalletStats._parseDouble(json['tvlUsd']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletAddress': walletAddress,
      'tvlUsd': tvlUsd,
    };
  }

  String get formattedTvl => '\$${tvlUsd.toStringAsFixed(2)}';
}

class PortalUser {
  final int referralCount;
  final String? referredBy;
  final String referralCode;
  final PortalUser? referredByUser;

  PortalUser({
    required this.referralCount,
    this.referredBy,
    required this.referralCode,
    this.referredByUser,
  });

  factory PortalUser.fromJson(Map<String, dynamic> json) {
    return PortalUser(
      referralCount: json['referralCount'] ?? 0,
      referredBy: json['referredBy'],
      referralCode: json['referralCode'] ?? '',
      referredByUser: json['referredByUser'] != null ? PortalUser.fromJson(json['referredByUser']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referralCount': referralCount,
      'referredBy': referredBy,
      'referralCode': referralCode,
      'referredByUser': referredByUser?.toJson(),
    };
  }
}

class ProtocolUsage {
  final String name;
  final int daysUsed;

  ProtocolUsage({
    required this.name,
    required this.daysUsed,
  });

  String get displayName {
    switch (name.toLowerCase()) {
      case 'daily_spin':
        return 'Daily Spin';
      case 'plume_staking':
        return 'Plume Staking';
      case 'rooster':
        return 'Rooster';
      default:
        return name.replaceAll('_', ' ').split(' ').map((word) => 
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
        ).join(' ');
    }
  }
}
class PlumePortalResponse {
  final PlumePortalData data;

  PlumePortalResponse({required this.data});

  factory PlumePortalResponse.fromJson(Map<String, dynamic> json) {
    return PlumePortalResponse(
      data: PlumePortalData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
    };
  }
}

class PlumePortalData {
  final PpScores ppScores;
  final WalletContext walletContext;

  PlumePortalData({
    required this.ppScores,
    required this.walletContext,
  });

  factory PlumePortalData.fromJson(Map<String, dynamic> json) {
    return PlumePortalData(
      ppScores: PpScores.fromJson(json['ppScores'] ?? {}),
      walletContext: WalletContext.fromJson(json['walletContext'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ppScores': ppScores.toJson(),
      'walletContext': walletContext.toJson(),
    };
  }
}

class PpScores {
  final XpData activeXp;
  final XpData prevXp;
  final List<String> top3PointsDeltasStrings;

  PpScores({
    required this.activeXp,
    required this.prevXp,
    required this.top3PointsDeltasStrings,
  });

  factory PpScores.fromJson(Map<String, dynamic> json) {
    return PpScores(
      activeXp: XpData.fromJson(json['activeXp'] ?? {}),
      prevXp: XpData.fromJson(json['prevXp'] ?? {}),
      top3PointsDeltasStrings: List<String>.from(
        json['top3PointsDeltasStrings'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeXp': activeXp.toJson(),
      'prevXp': prevXp.toJson(),
      'top3PointsDeltasStrings': top3PointsDeltasStrings,
    };
  }

  int get xpDelta => activeXp.totalXp - prevXp.totalXp;

  double get xpGrowthPercentage {
    if (prevXp.totalXp == 0) return 0.0;
    return ((xpDelta / prevXp.totalXp) * 100);
  }
}

class XpData {
  final int totalXp;
  final int userSelfXp;
  final int referralBonusXp;
  final String dateStr;

  XpData({
    required this.totalXp,
    this.userSelfXp = 0,
    this.referralBonusXp = 0,
    required this.dateStr,
  });

  factory XpData.fromJson(Map<String, dynamic> json) {
    return XpData(
      totalXp: json['totalXp'] ?? 0,
      userSelfXp: json['userSelfXp'] ?? 0,
      referralBonusXp: json['referralBonusXp'] ?? 0,
      dateStr: json['dateStr'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalXp': totalXp,
      'userSelfXp': userSelfXp,
      'referralBonusXp': referralBonusXp,
      'dateStr': dateStr,
    };
  }

  DateTime? get dateTime {
    try {
      final parts = dateStr.split('_');
      if (parts.length != 2) return null;

      final datePart = parts[0];
      final timePart = parts[1];

      return DateTime.parse('${datePart}T$timePart');
    } catch (e) {
      return null;
    }
  }

  String get formattedDate {
    final date = dateTime;
    if (date == null) return dateStr;

    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class WalletContext {
  final String address;
  final bool isAuthenticatedUser;
  final bool isAdmin;

  WalletContext({
    required this.address,
    this.isAuthenticatedUser = false,
    this.isAdmin = false,
  });

  factory WalletContext.fromJson(Map<String, dynamic> json) {
    return WalletContext(
      address: json['address'] ?? '',
      isAuthenticatedUser: json['isAuthenticatedUser'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'isAuthenticatedUser': isAuthenticatedUser,
      'isAdmin': isAdmin,
    };
  }

  String get shortAddress {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  bool get isValidEthereumAddress {
    return RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address);
  }
}

class BadgesResponse {
  final BadgesData data;

  BadgesResponse({required this.data});

  factory BadgesResponse.fromJson(Map<String, dynamic> json) {
    return BadgesResponse(
      data: BadgesData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
    };
  }
}

class BadgesData {
  final List<Badge> badges;
  final WalletContext walletContext;

  BadgesData({
    required this.badges,
    required this.walletContext,
  });

  factory BadgesData.fromJson(Map<String, dynamic> json) {
    return BadgesData(
      badges: (json['badges'] as List<dynamic>? ?? [])
          .map((badgeJson) => Badge.fromJson(badgeJson as Map<String, dynamic>))
          .toList(),
      walletContext: WalletContext.fromJson(json['walletContext'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badges': badges.map((badge) => badge.toJson()).toList(),
      'walletContext': walletContext.toJson(),
    };
  }

  List<Badge> get earnedBadges => badges.where((badge) => badge.isEarned).toList();
  List<Badge> get availableBadges => badges.where((badge) => !badge.isEarned && badge.isVisible).toList();
  int get totalPlumePoints => badges.where((badge) => badge.isEarned).fold(0, (sum, badge) => sum + badge.pp);

  List<Badge> get questBadges => badges.where((badge) => badge.id.contains('quest')).toList();
  List<Badge> get roleBadges => badges.where((badge) => badge.title.toLowerCase().contains('role')).toList();
  List<Badge> get eventBadges => badges.where((badge) => 
    badge.id.contains('easter') || 
    badge.id.contains('carnaval') || 
    badge.id.contains('lunar') ||
    badge.id.contains('songkran') ||
    badge.id.contains('july')
  ).toList();
  List<Badge> get guardianBadges => badges.where((badge) => badge.id.contains('guardians')).toList();
}

class Badge {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final bool isVisible;
  final int pp;
  final DateTime createdAt;
  final DateTime? earnedAt;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.isVisible,
    required this.pp,
    required this.createdAt,
    this.earnedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      isVisible: json['isVisible'] ?? true,
      pp: json['pp'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      earnedAt: json['earnedAt'] != null ? DateTime.tryParse(json['earnedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'isVisible': isVisible,
      'pp': pp,
      'createdAt': createdAt.toIso8601String(),
      'earnedAt': earnedAt?.toIso8601String(),
    };
  }

  bool get isEarned => earnedAt != null;
  bool get hasPoints => pp > 0;

  BadgeCategory get category {
    if (id.contains('quest')) return BadgeCategory.quest;
    if (title.toLowerCase().contains('role')) return BadgeCategory.role;
    if (id.contains('guardians')) return BadgeCategory.guardian;
    if (_isEventBadge()) return BadgeCategory.event;
    if (id.contains('staker') || id.contains('nest') || id.contains('elixir')) return BadgeCategory.protocol;
    return BadgeCategory.other;
  }

  bool _isEventBadge() {
    return id.contains('easter') || 
           id.contains('carnaval') || 
           id.contains('lunar') ||
           id.contains('songkran') ||
           id.contains('july') ||
           id.contains('goon_madness');
  }

  IconData get categoryIcon {
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

  Color get categoryColor {
    switch (category) {
      case BadgeCategory.quest:
        return const Color(0xFF10B981);
      case BadgeCategory.role:
        return const Color(0xFF8B5CF6);
      case BadgeCategory.guardian:
        return const Color(0xFFEF4444);
      case BadgeCategory.event:
        return const Color(0xFFFFB800);
      case BadgeCategory.protocol:
        return const Color(0xFF06B6D4);
      case BadgeCategory.other:
        return const Color(0xFF6B7280);
    }
  }
}

enum BadgeCategory {
  quest,
  role,
  guardian,
  event,
  protocol,
  other,
}

enum PlumePortalLoadingState {
  initial,
  loading,
  success,
  error,
}

class PlumePortalState {
  final PlumePortalLoadingState loadingState;
  final PlumePortalResponse? data;
  final String? errorMessage;

  PlumePortalState({
    this.loadingState = PlumePortalLoadingState.initial,
    this.data,
    this.errorMessage,
  });

  PlumePortalState copyWith({
    PlumePortalLoadingState? loadingState,
    PlumePortalResponse? data,
    String? errorMessage,
  }) {
    return PlumePortalState(
      loadingState: loadingState ?? this.loadingState,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => loadingState == PlumePortalLoadingState.loading;
  bool get hasData => data != null && loadingState == PlumePortalLoadingState.success;
  bool get hasError => loadingState == PlumePortalLoadingState.error;
}

class SkySocietyResponse {
  final SkySocietyData data;

  SkySocietyResponse({required this.data});

  factory SkySocietyResponse.fromJson(Map<String, dynamic> json) {
    return SkySocietyResponse(
      data: SkySocietyData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
    };
  }
}

class SkySocietyData {
  final String? skySocietyTier;
  final List<dynamic>? socialConnections;

  SkySocietyData({
    this.skySocietyTier,
    this.socialConnections,
  });

  factory SkySocietyData.fromJson(Map<String, dynamic> json) {
    return SkySocietyData(
      skySocietyTier: json['skySocietyTier'] as String?,
      socialConnections: json['socialConnections'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skySocietyTier': skySocietyTier,
      'socialConnections': socialConnections,
    };
  }

  bool get hasTier => skySocietyTier != null && 
                     skySocietyTier!.isNotEmpty && 
                     skySocietyTier!.toLowerCase() != 'none' &&
                     _isValidTier();

  String get displayTier => skySocietyTier ?? 'No Tier';

  bool _isValidTier() {
    if (skySocietyTier == null) return false;

    final validTiers = {
      'phoenix', 'eagle', 'hawk', 'falcon',
      'legendary', 'diamond', 'platinum', 'gold', 'silver', 'bronze'
    };

    return validTiers.contains(skySocietyTier!.toLowerCase());
  }

  String get tierCategory {
    if (!hasTier) return 'none';

    final birdTiers = {'phoenix', 'eagle', 'hawk', 'falcon'};
    final metalTiers = {'legendary', 'diamond', 'platinum', 'gold', 'silver', 'bronze'};

    final tierLower = skySocietyTier!.toLowerCase();

    if (birdTiers.contains(tierLower)) return 'bird';
    if (metalTiers.contains(tierLower)) return 'metal';

    return 'unknown';
  }

  List<Color> get tierColors {
    if (skySocietyTier == null || !hasTier) {
      return [const Color(0xFF6B7280), const Color(0xFF4B5563)];
    }

    switch (skySocietyTier!.toLowerCase()) {
      case 'phoenix':
        return [const Color(0xFFFF4500), const Color(0xFFFF6347)];
      case 'eagle':
        return [const Color(0xFF8B4513), const Color(0xFFA0522D)];
      case 'hawk':
        return [const Color(0xFF2F4F4F), const Color(0xFF708090)];
      case 'falcon':
        return [const Color(0xFF4682B4), const Color(0xFF5F9EA0)];

      case 'legendary':
        return [const Color(0xFFFFD700), const Color(0xFFFF6B35)];
      case 'diamond':
        return [const Color(0xFF60A5FA), const Color(0xFF3B82F6)];
      case 'platinum':
        return [const Color(0xFFE5E7EB), const Color(0xFFC0C0C0)];
      case 'gold':
        return [const Color(0xFFFFB800), const Color(0xFFFF8C00)];
      case 'silver':
        return [const Color(0xFFC0C0C0), const Color(0xFF9CA3AF)];
      case 'bronze':
        return [const Color(0xFFCD7F32), const Color(0xFFA0522D)];
      default:
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
    }
  }

  IconData get tierIcon {
    if (skySocietyTier == null || !hasTier) return Icons.stars_outlined;

    switch (skySocietyTier!.toLowerCase()) {
      case 'phoenix':
        return Icons.local_fire_department;
      case 'eagle':
        return Icons.flight;
      case 'hawk':
        return Icons.visibility;
      case 'falcon':
        return Icons.speed;

      case 'legendary':
        return Icons.auto_awesome;
      case 'diamond':
        return Icons.diamond;
      case 'platinum':
        return Icons.workspace_premium;
      case 'gold':
        return Icons.star;
      case 'silver':
        return Icons.star_border;
      case 'bronze':
        return Icons.star_outline;
      default:
        return Icons.stars;
    }
  }

  int get skySocietyRank {
    if (!hasTier) return 0;

    switch (skySocietyTier!.toLowerCase()) {
      case 'phoenix': return 10;
      case 'eagle': return 9;
      case 'hawk': return 8;
      case 'falcon': return 7;

      case 'legendary': return 6;
      case 'diamond': return 5;
      case 'platinum': return 4;
      case 'gold': return 3;
      case 'silver': return 2;
      case 'bronze': return 1;
      default: return 0;
    }
  }
}

class DailySpinResponse {
  final DailySpinData data;

  DailySpinResponse({required this.data});

  factory DailySpinResponse.fromJson(Map<String, dynamic> json) {
    return DailySpinResponse(
      data: DailySpinData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
    };
  }
}

class DailySpinData {
  final List<SpinRecord> spins;
  final SpinSummary summary;
  final WalletContext walletContext;

  DailySpinData({
    required this.spins,
    required this.summary,
    required this.walletContext,
  });

  factory DailySpinData.fromJson(Map<String, dynamic> json) {
    List<dynamic> spinList = json['spins'] as List<dynamic>? ?? 
                           json['spinHistory'] as List<dynamic>? ?? [];

    return DailySpinData(
      spins: spinList
          .map((spinJson) => SpinRecord.fromJson(spinJson as Map<String, dynamic>))
          .toList(),
      summary: SpinSummary.fromJson(json['summary'] ?? {}),
      walletContext: WalletContext.fromJson(json['walletContext'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spins': spins.map((spin) => spin.toJson()).toList(),
      'summary': summary.toJson(),
      'walletContext': walletContext.toJson(),
    };
  }

  List<SpinRecord> get recentSpins => spins.take(10).toList();
  List<SpinRecord> get todaySpins {
    final today = DateTime.now();
    return spins.where((spin) => 
      spin.dateTime?.day == today.day &&
      spin.dateTime?.month == today.month &&
      spin.dateTime?.year == today.year
    ).toList();
  }

  List<SpinRecord> getSpinsForDateRange(DateTime startDate, DateTime endDate) {
    return spins.where((spin) {
      final spinDate = spin.dateTime;
      if (spinDate == null) return false;
      return spinDate.isAfter(startDate) && spinDate.isBefore(endDate);
    }).toList();
  }

  List<SpinRecord> getSpinsForLastDays(int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    return getSpinsForDateRange(startDate, now);
  }

  Map<String, double> get rewardsByType {
    final rewards = <String, double>{};
    for (final spin in spins) {
      final rewardType = spin.reward.type;
      final amount = spin.reward.numericAmount;
      rewards[rewardType] = (rewards[rewardType] ?? 0.0) + amount;
    }
    return rewards;
  }

  double get successRate {
    if (spins.isEmpty) return 0.0;
    final successfulSpins = spins.where((spin) => spin.reward.hasReward).length;
    return (successfulSpins / spins.length) * 100;
  }

  double get averageRewardsPerDay {
    if (spins.isEmpty) return 0.0;
    final totalDays = _getUniqueDates().length;
    if (totalDays == 0) return 0.0;
    return summary.totalRewards / totalDays;
  }

  Set<String> _getUniqueDates() {
    return spins
        .where((spin) => spin.dateTime != null)
        .map((spin) => '${spin.dateTime!.year}-${spin.dateTime!.month}-${spin.dateTime!.day}')
        .toSet();
  }
}

class SpinRecord {
  final String id;
  final String walletAddress;
  final SpinReward reward;
  final String dateStr;
  final DateTime? timestamp;
  final bool isSuccessful;
  final String? transactionHash;

  SpinRecord({
    required this.id,
    required this.walletAddress,
    required this.reward,
    required this.dateStr,
    this.timestamp,
    required this.isSuccessful,
    this.transactionHash,
  });

  factory SpinRecord.fromJson(Map<String, dynamic> json) {
    String rewardCategory = json['rewardCategory'] ?? 'EMPTY';
    String rewardAmount = json['rewardAmount']?.toString() ?? '0';
    String txHash = json['txHash'] ?? json['transactionHash'] ?? '';

    SpinReward reward;
    if (rewardCategory == 'Nothing' || rewardCategory == 'EMPTY') {
      reward = SpinReward(
        type: 'EMPTY',
        amount: '0',
        displayText: 'No Reward',
        isRare: false,
        multiplier: 1.0,
        xp: 0,
      );
    } else {
      String rewardType = 'UNKNOWN';
      if (rewardCategory.toLowerCase().contains('plume')) {
        rewardType = 'PLUME';
      } else if (rewardCategory.toLowerCase().contains('xp')) {
        rewardType = 'XP';
      } else if (rewardCategory.toLowerCase().contains('usdc')) {
        rewardType = 'USDC';
      } else if (rewardCategory.toLowerCase().contains('ticket')) {
        rewardType = 'TICKET';
      } else {
        rewardType = rewardCategory.toUpperCase();
      }

      reward = SpinReward(
        type: rewardType,
        amount: rewardAmount,
        displayText: '$rewardAmount $rewardCategory',
        isRare: false,
        multiplier: 1.0,
        xp: rewardType == 'XP' ? int.tryParse(rewardAmount) ?? 0 : 0,
      );
    }

    DateTime? parsedTimestamp;
    if (json['timestamp'] != null) {
      if (json['timestamp'] is int) {
        parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp'] * 1000);
      } else {
        parsedTimestamp = DateTime.tryParse(json['timestamp'].toString());
      }
    }

    return SpinRecord(
      id: json['txHash'] ?? json['id']?.toString() ?? '',
      walletAddress: json['walletAddress'] ?? '',
      reward: reward,
      dateStr: json['dateStr'] ?? '',
      timestamp: parsedTimestamp,
      isSuccessful: rewardCategory != 'Nothing' && rewardCategory != 'EMPTY',
      transactionHash: txHash,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletAddress': walletAddress,
      'reward': reward.toJson(),
      'dateStr': dateStr,
      'timestamp': timestamp?.toIso8601String(),
      'isSuccessful': isSuccessful,
      'transactionHash': transactionHash,
    };
  }

  DateTime? get dateTime {
    print('🕒 SpinRecord.dateTime getter called for record ID: $id');
    print('   timestamp: $timestamp');
    print('   dateStr: "$dateStr"');

    if (timestamp != null) {
      print('   ✅ Using timestamp: $timestamp');
      return timestamp;
    }

    try {
      print('   📝 Attempting to parse dateStr: "$dateStr"');

      final parts = dateStr.split('_');
      if (parts.length == 2) {
        print('   🔍 Format: Underscore separated (YYYY-MM-DD_HH:MM:SS)');
        final datePart = parts[0];
        final timePart = parts[1];
        final isoString = '${datePart}T$timePart';
        print('   🔄 Converting to ISO: "$isoString"');
        final parsed = DateTime.parse(isoString);
        print('   ✅ Successfully parsed: $parsed');
        return parsed;
      }

      if (dateStr.contains('T')) {
        print('   🔍 Format: ISO 8601 format detected');
        final parsed = DateTime.parse(dateStr);
        print('   ✅ Successfully parsed ISO: $parsed');
        return parsed;
      }

      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
        print('   🔍 Format: Date only (YYYY-MM-DD)');
        final parsed = DateTime.parse('${dateStr}T00:00:00');
        print('   ✅ Successfully parsed date only: $parsed');
        return parsed;
      }

      if (RegExp(r'^\d{10,13}$').hasMatch(dateStr)) {
        print('   🔍 Format: Unix timestamp string detected');
        final timestamp = int.tryParse(dateStr);
        if (timestamp != null) {
          final isSeconds = dateStr.length == 10;
          final milliseconds = isSeconds ? timestamp * 1000 : timestamp;
          final parsed = DateTime.fromMillisecondsSinceEpoch(milliseconds);
          print('   ✅ Successfully parsed unix timestamp: $parsed');
          return parsed;
        }
      }

      final alternativeFormats = [
        dateStr.replaceAll('/', '-'), // Convert slashes to dashes
        dateStr.replaceAll(' ', 'T'), // Convert space to T
        dateStr.replaceAll('-', '/'), // Convert dashes to slashes
      ];

      for (final format in alternativeFormats) {
        try {
          print('   🔄 Trying alternative format: "$format"');
          final parsed = DateTime.parse(format);
          print('   ✅ Successfully parsed alternative: $parsed');
          return parsed;
        } catch (altE) {
          print('   ❌ Alternative format failed: $altE');
        }
      }

      print('   ❌ All parsing strategies failed for dateStr: "$dateStr"');
      return null;
    } catch (e) {
      print('   ❌ Date parsing error for "$dateStr": $e');
      return null;
    }
  }

  String get formattedDate {
    final date = dateTime;
    if (date == null) return dateStr;
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String get relativeTime {
    final date = dateTime;
    if (date == null) return 'Unknown time';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

class SpinReward {
  final String type;
  final String amount;
  final String displayText;
  final bool isRare;
  final double? multiplier;
  final int xp;

  SpinReward({
    required this.type,
    required this.amount,
    required this.displayText,
    this.isRare = false,
    this.multiplier,
    required this.xp,
  });

  factory SpinReward.fromJson(Map<String, dynamic> json) {
    return SpinReward(
      type: json['type'] ?? 'EMPTY',
      amount: json['amount']?.toString() ?? '0',
      displayText: json['displayText'] ?? json['amount']?.toString() ?? '0',
      isRare: json['isRare'] ?? false,
      multiplier: json['multiplier']?.toDouble(),
      xp: json['xp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'displayText': displayText,
      'isRare': isRare,
      'multiplier': multiplier,
    };
  }

  bool get hasReward => type != 'EMPTY' && numericAmount > 0;
  bool get isPlumeReward => type == 'PLUME';
  bool get isXpReward => type == 'XP';
  bool get isEmpty => type == 'EMPTY' || numericAmount == 0;

  double get numericAmount {
    try {
      if (isPlumeReward && amount.contains('e')) {
        final weiAmount = double.parse(amount);
        return weiAmount / 1e18;
      }
      return double.parse(amount.replaceAll(RegExp(r'[^0-9.]'), ''));
    } catch (e) {
      return 0.0;
    }
  }

  String get formattedAmount {
    if (isEmpty) return 'No Reward';

    final value = numericAmount;
    if (isPlumeReward) {
      if (value >= 1.0) {
        return '${value.toStringAsFixed(3)} PLUME';
      } else {
        return '${value.toStringAsFixed(6)} PLUME';
      }
    } else if (isXpReward) {
      return '${value.toStringAsFixed(0)} XP';
    } else {
      return displayText.isNotEmpty ? displayText : amount;
    }
  }

  Color get rewardColor {
    if (isEmpty) return const Color(0xFF6B7280);
    if (isRare) return const Color(0xFFFFD700);

    switch (type) {
      case 'PLUME':
        return const Color(0xFF8B5CF6);
      case 'XP':
        return const Color(0xFF10B981);
      case 'USDC':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF06B6D4);
    }
  }

  IconData get rewardIcon {
    if (isEmpty) return Icons.close;

    switch (type) {
      case 'PLUME':
        return Icons.token;
      case 'XP':
        return Icons.stars;
      case 'USDC':
        return Icons.attach_money;
      default:
        return Icons.card_giftcard;
    }
  }
}

class SpinSummary {
  final int totalSpins;
  final int successfulSpins;
  final double totalRewards;
  final int currentStreak;
  final int longestStreak;
  final String favoriteRewardType;
  final int totalDaysActive;
  final DateTime? firstSpinDate;
  final DateTime? lastSpinDate;
  final Map<String, int> rewardTypeCount;

  SpinSummary({
    required this.totalSpins,
    required this.successfulSpins,
    required this.totalRewards,
    required this.currentStreak,
    required this.longestStreak,
    required this.favoriteRewardType,
    required this.totalDaysActive,
    this.firstSpinDate,
    this.lastSpinDate,
    required this.rewardTypeCount,
  });

  factory SpinSummary.fromJson(Map<String, dynamic> json) {
    return SpinSummary(
      totalSpins: json['totalSpins'] ?? 0,
      successfulSpins: json['successfulSpins'] ?? 0,
      totalRewards: PortalWalletStats._parseDouble(json['totalRewards']),
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      favoriteRewardType: json['favoriteRewardType'] ?? 'EMPTY',
      totalDaysActive: json['totalDaysActive'] ?? 0,
      firstSpinDate: json['firstSpinDate'] != null ? DateTime.tryParse(json['firstSpinDate']) : null,
      lastSpinDate: json['lastSpinDate'] != null ? DateTime.tryParse(json['lastSpinDate']) : null,
      rewardTypeCount: Map<String, int>.from(json['rewardTypeCount'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSpins': totalSpins,
      'successfulSpins': successfulSpins,
      'totalRewards': totalRewards,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'favoriteRewardType': favoriteRewardType,
      'totalDaysActive': totalDaysActive,
      'firstSpinDate': firstSpinDate?.toIso8601String(),
      'lastSpinDate': lastSpinDate?.toIso8601String(),
      'rewardTypeCount': rewardTypeCount,
    };
  }

  double get successRate {
    if (totalSpins == 0) return 0.0;
    return (successfulSpins / totalSpins) * 100;
  }

  double get averageRewardsPerSpin {
    if (totalSpins == 0) return 0.0;
    return totalRewards / totalSpins;
  }

  double get averageRewardsPerDay {
    if (totalDaysActive == 0) return 0.0;
    return totalRewards / totalDaysActive;
  }

  String get formattedTotalRewards {
    if (totalRewards >= 1.0) {
      return '${totalRewards.toStringAsFixed(3)} PLUME';
    } else {
      return '${totalRewards.toStringAsFixed(6)} PLUME';
    }
  }

  String get formattedSuccessRate => '${successRate.toStringAsFixed(1)}%';

  String get streakDescription {
    if (currentStreak == 0) {
      return 'No active streak';
    } else if (currentStreak == 1) {
      return '1 day streak';
    } else {
      return '$currentStreak days streak';
    }
  }

  String get activityLevel {
    final score = (totalSpins * 2) + (currentStreak * 10) + (longestStreak * 5);

    if (score >= 1000) return 'Spin Master';
    if (score >= 500) return 'Daily Spinner';
    if (score >= 200) return 'Regular Player';
    if (score >= 50) return 'Casual Spinner';
    return 'Getting Started';
  }

  String get mostRewardingType {
    if (rewardTypeCount.isEmpty) return 'None';

    return rewardTypeCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

class Season1Response {
  final Season1Data data;

  Season1Response({
    required this.data,
  });

  factory Season1Response.fromJson(Map<String, dynamic> json) {
    return Season1Response(
      data: Season1Data.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
    };
  }
}

class Season1Data {
  final Season1Stats season1Stats;
  final WalletContext walletContext;

  Season1Data({
    required this.season1Stats,
    required this.walletContext,
  });

  factory Season1Data.fromJson(Map<String, dynamic> json) {
    return Season1Data(
      season1Stats: Season1Stats.fromJson(json['season1Stats'] ?? {}),
      walletContext: WalletContext.fromJson(json['walletContext'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'season1Stats': season1Stats.toJson(),
      'walletContext': walletContext.toJson(),
    };
  }
}

class Season1Stats {
  final int miles;
  final String flightClass;
  final int stamps;
  final int referrals;

  Season1Stats({
    required this.miles,
    required this.flightClass,
    required this.stamps,
    required this.referrals,
  });

  factory Season1Stats.fromJson(Map<String, dynamic> json) {
    return Season1Stats(
      miles: json['miles'] ?? 0,
      flightClass: json['flightClass'] ?? '',
      stamps: json['stamps'] ?? 0,
      referrals: json['referrals'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'miles': miles,
      'flightClass': flightClass,
      'stamps': stamps,
      'referrals': referrals,
    };
  }

  bool get hasFlightClass => flightClass.isNotEmpty;

  bool get hasData => miles > 0 || stamps > 0 || referrals > 0 || hasFlightClass;

  String get flightClassDisplay => hasFlightClass ? flightClass.toUpperCase() : 'NO CLASS';

  Color get flightClassColor {
    switch (flightClass.toLowerCase()) {
      case 'private':
        return const Color(0xFFDC2626);
      case 'first':
      case 'first class':
        return const Color(0xFFFFD700);
      case 'business':
      case 'business class':
        return const Color(0xFF8B5CF6);
      case 'premium economy':
      case 'premium':
        return const Color(0xFF06B6D4);
      case 'economy':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData get flightClassIcon {
    switch (flightClass.toLowerCase()) {
      case 'private':
        return Icons.private_connectivity;
      case 'first':
      case 'first class':
        return Icons.flight_class;
      case 'business':
      case 'business class':
        return Icons.business_center;
      case 'premium economy':
      case 'premium':
        return Icons.event_seat;
      case 'economy':
        return Icons.airline_seat_recline_normal;
      default:
        return Icons.flight;
    }
  }

  String get flightClassDescription {
    switch (flightClass.toLowerCase()) {
      case 'private':
        return 'Exclusive Private Jet';
      case 'first':
      case 'first class':
        return 'Luxury Experience';
      case 'business':
      case 'business class':
        return 'Enhanced Comfort';
      case 'premium economy':
      case 'premium':
        return 'Extra Benefits';
      case 'economy':
        return 'Standard Service';
      default:
        return 'Unassigned Class';
    }
  }

  String get activityLevel {
    final score = (miles * 0.1) + (stamps * 5) + (referrals * 10);

    if (score >= 100) return 'Frequent Flyer';
    if (score >= 50) return 'Regular Traveler';
    if (score >= 20) return 'Occasional Flyer';
    if (score > 0) return 'New Passenger';
    return 'Not Active';
  }

  String get formattedMiles {
    if (miles >= 1000000) {
      return '${(miles / 1000000).toStringAsFixed(1)}M';
    } else if (miles >= 1000) {
      return '${(miles / 1000).toStringAsFixed(1)}K';
    } else {
      return miles.toString();
    }
  }

  double get milesProgress {
    const milestones = [1000, 5000, 10000, 25000, 50000, 100000];

    for (int milestone in milestones) {
      if (miles < milestone) {
        final previousMilestone = milestones.indexOf(milestone) == 0 
            ? 0 
            : milestones[milestones.indexOf(milestone) - 1];
        return (miles - previousMilestone) / (milestone - previousMilestone);
      }
    }
    return 1.0;
  }

  int get nextMilestone {
    const milestones = [1000, 5000, 10000, 25000, 50000, 100000];

    for (int milestone in milestones) {
      if (miles < milestone) {
        return milestone;
      }
    }
    return milestones.last;
  }
}
