import 'package:json_annotation/json_annotation.dart';

part 'portal_stats_models.g.dart';

@JsonSerializable()
class PortalStatsResponse {
  @JsonKey(name: 'data')
  final PortalStatsData data;

  const PortalStatsResponse({
    required this.data,
  });

  factory PortalStatsResponse.fromJson(Map<String, dynamic> json) => 
      _$PortalStatsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PortalStatsResponseToJson(this);

  PortalWalletContext get walletContext => data.walletContext;
}

@JsonSerializable()
class PortalStatsData {
  @JsonKey(name: 'walletAddress')
  final String walletAddress;

  @JsonKey(name: 'stats')
  final WalletStats stats;

  @JsonKey(name: 'walletContext')
  final PortalWalletContext walletContext;

  const PortalStatsData({
    required this.walletAddress,
    required this.stats,
    required this.walletContext,
  });

  factory PortalStatsData.fromJson(Map<String, dynamic> json) => 
      _$PortalStatsDataFromJson(json);

  Map<String, dynamic> toJson() => _$PortalStatsDataToJson(this);
}

@JsonSerializable()
class WalletStats {
  @JsonKey(name: 'walletAddress')
  final String walletAddress;

  @JsonKey(name: 'bridgedTotal')
  final double bridgedTotal;

  @JsonKey(name: 'swapVolume')
  final double swapVolume;

  @JsonKey(name: 'swapCount')
  final int swapCount;

  @JsonKey(name: 'tvlTotalUsd')
  final double tvlTotalUsd;

  @JsonKey(name: 'protocolsUsed')
  final int protocolsUsed;

  @JsonKey(name: 'totalXp')
  final int totalXp;

  @JsonKey(name: 'dateStr')
  final String dateStr;

  @JsonKey(name: 'currentTvlLevels')
  final String currentTvlLevels;

  @JsonKey(name: 'longestTvlStreak')
  final int longestTvlStreak;

  @JsonKey(name: 'plumeStaked')
  final double plumeStaked;

  @JsonKey(name: 'plumeStakingStreak')
  final int plumeStakingStreak;

  @JsonKey(name: 'plumeStakingClaimedAmount')
  final PlumeStakingClaimed plumeStakingClaimedAmount;

  @JsonKey(name: 'TVL')
  final double tvl;

  @JsonKey(name: 'referrals')
  final int referrals;

  @JsonKey(name: 'referredBy')
  final String? referredBy;

  @JsonKey(name: 'referralCode')
  final String referralCode;

  @JsonKey(name: 'referredByUser')
  final String? referredByUser;

  @JsonKey(name: 'completedQuests')
  final int completedQuests;

  @JsonKey(name: 'dailySpinStreak')
  final int dailySpinStreak;

  @JsonKey(name: 'plumeRewards')
  final PlumeRewards plumeRewards;

  @JsonKey(name: 'bgRank')
  final int? bgRank;

  @JsonKey(name: 'realTvlUsd')
  final double realTvlUsd;

  @JsonKey(name: 'longestSwapStreakWeeks')
  final int longestSwapStreakWeeks;

  @JsonKey(name: 'adjustmentPoints')
  final int adjustmentPoints;

  @JsonKey(name: 'protectorsOfPlumePoints')
  final int protectorsOfPlumePoints;

  @JsonKey(name: 'badgePoints')
  final int badgePoints;

  @JsonKey(name: 'userSelfXp')
  final int userSelfXp;

  @JsonKey(name: 'referralBonusXp')
  final int referralBonusXp;

  @JsonKey(name: 'xpRank')
  final int xpRank;

  @JsonKey(name: 'protocol1')
  final String protocol1;

  @JsonKey(name: 'daysUsed1')
  final int daysUsed1;

  @JsonKey(name: 'protocol2')
  final String protocol2;

  @JsonKey(name: 'daysUsed2')
  final int daysUsed2;

  @JsonKey(name: 'protocol3')
  final String protocol3;

  @JsonKey(name: 'daysUsed3')
  final int daysUsed3;

  @JsonKey(name: 'plumeStakingLongestStreakDays')
  final int plumeStakingLongestStreakDays;

  @JsonKey(name: 'currentPlumeStakingTotalTokens')
  final double currentPlumeStakingTotalTokens;

  @JsonKey(name: 'referralCount')
  final int referralCount;

  @JsonKey(name: 'everActiveSnapshot')
  final bool everActiveSnapshot;

  @JsonKey(name: 'plumeStakingPointsEarned')
  final int plumeStakingPointsEarned;

  @JsonKey(name: 'plumeStakingBonusPointsEarned')
  final int plumeStakingBonusPointsEarned;

  @JsonKey(name: 'battleGroup')
  final int battleGroup;

  @JsonKey(name: 'walletTvl')
  final WalletTvl walletTvl;

  @JsonKey(name: 'user')
  final PortalUser user;

  @JsonKey(name: 'totalPnl')
  final double totalPnl;

  @JsonKey(name: 'winRate')
  final double winRate;

  @JsonKey(name: 'totalRewards')
  final double totalRewards;

  const WalletStats({
    required this.walletAddress,
    required this.bridgedTotal,
    required this.swapVolume,
    required this.swapCount,
    required this.tvlTotalUsd,
    required this.protocolsUsed,
    required this.totalXp,
    required this.dateStr,
    required this.currentTvlLevels,
    required this.longestTvlStreak,
    required this.plumeStaked,
    required this.plumeStakingStreak,
    required this.plumeStakingClaimedAmount,
    required this.tvl,
    required this.referrals,
    this.referredBy,
    required this.referralCode,
    this.referredByUser,
    required this.completedQuests,
    required this.dailySpinStreak,
    required this.plumeRewards,
    this.bgRank,
    required this.realTvlUsd,
    required this.longestSwapStreakWeeks,
    required this.adjustmentPoints,
    required this.protectorsOfPlumePoints,
    required this.badgePoints,
    required this.userSelfXp,
    required this.referralBonusXp,
    required this.xpRank,
    required this.protocol1,
    required this.daysUsed1,
    required this.protocol2,
    required this.daysUsed2,
    required this.protocol3,
    required this.daysUsed3,
    required this.plumeStakingLongestStreakDays,
    required this.currentPlumeStakingTotalTokens,
    required this.referralCount,
    required this.everActiveSnapshot,
    required this.plumeStakingPointsEarned,
    required this.plumeStakingBonusPointsEarned,
    required this.battleGroup,
    required this.walletTvl,
    required this.user,
    required this.totalPnl,
    required this.winRate,
    required this.totalRewards,
  });

  factory WalletStats.fromJson(Map<String, dynamic> json) => 
      _$WalletStatsFromJson(json);

  Map<String, dynamic> toJson() => _$WalletStatsToJson(this);

  String get formattedBridgedTotal => '\$${bridgedTotal.toStringAsFixed(2)}';
  String get formattedSwapVolume => '\$${swapVolume.toStringAsFixed(2)}';
  String get formattedTvl => '\$${tvl.toStringAsFixed(2)}';
  String get formattedPlumeStaked => '${plumeStaked.toStringAsFixed(3)} PLUME';
  String get formattedTotalXp => totalXp.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

  List<ProtocolUsage> get topProtocols => [
    ProtocolUsage(name: protocol1, daysUsed: daysUsed1),
    ProtocolUsage(name: protocol2, daysUsed: daysUsed2),
    ProtocolUsage(name: protocol3, daysUsed: daysUsed3),
  ];

  String get activityLevel {
    if (totalXp >= 50000) return 'Very Active';
    if (totalXp >= 20000) return 'Active';
    if (totalXp >= 5000) return 'Moderate';
    if (totalXp > 0) return 'Beginner';
    return 'No Activity';
  }

  double get stakingPerformance {
    if (plumeStakingStreak == 0) return 0.0;
    return (plumeStakingStreak / plumeStakingLongestStreakDays.clamp(1, double.infinity)) * 100;
  }
}

@JsonSerializable()
class PlumeStakingClaimed {
  @JsonKey(name: 'plume')
  final double plume;

  @JsonKey(name: 'usdc')
  final double usdc;

  const PlumeStakingClaimed({
    required this.plume,
    required this.usdc,
  });

  factory PlumeStakingClaimed.fromJson(Map<String, dynamic> json) => 
      _$PlumeStakingClaimedFromJson(json);

  Map<String, dynamic> toJson() => _$PlumeStakingClaimedToJson(this);

  String get formattedPlume => '${plume.toStringAsFixed(6)} PLUME';
  String get formattedUsdc => '\$${usdc.toStringAsFixed(2)}';
}

@JsonSerializable()
class PlumeRewards {
  @JsonKey(name: 'spin')
  final int spin;

  @JsonKey(name: 'staking')
  final int staking;

  @JsonKey(name: 'royco')
  final int royco;

  @JsonKey(name: 'merkl')
  final int merkl;

  const PlumeRewards({
    required this.spin,
    required this.staking,
    required this.royco,
    required this.merkl,
  });

  factory PlumeRewards.fromJson(Map<String, dynamic> json) => 
      _$PlumeRewardsFromJson(json);

  Map<String, dynamic> toJson() => _$PlumeRewardsToJson(this);

  double get spinPlume => spin / 1e18;
  double get stakingPlume => staking / 1e18;
  double get roycoPlume => royco / 1e18;
  double get merklPlume => merkl / 1e18;

  double get totalPlume => spinPlume + stakingPlume + roycoPlume + merklPlume;

  String get formattedTotalPlume => '${totalPlume.toStringAsFixed(3)} PLUME';
}

@JsonSerializable()
class WalletTvl {
  @JsonKey(name: 'walletAddress')
  final String walletAddress;

  @JsonKey(name: 'tvlUsd')
  final double tvlUsd;

  const WalletTvl({
    required this.walletAddress,
    required this.tvlUsd,
  });

  factory WalletTvl.fromJson(Map<String, dynamic> json) => 
      _$WalletTvlFromJson(json);

  Map<String, dynamic> toJson() => _$WalletTvlToJson(this);

  String get formattedTvl => '\$${tvlUsd.toStringAsFixed(2)}';
}

@JsonSerializable()
class PortalUser {
  @JsonKey(name: 'referralCount')
  final int referralCount;

  @JsonKey(name: 'referredBy')
  final String? referredBy;

  @JsonKey(name: 'referralCode')
  final String referralCode;

  @JsonKey(name: 'referredByUser')
  final String? referredByUser;

  const PortalUser({
    required this.referralCount,
    this.referredBy,
    required this.referralCode,
    this.referredByUser,
  });

  factory PortalUser.fromJson(Map<String, dynamic> json) => 
      _$PortalUserFromJson(json);

  Map<String, dynamic> toJson() => _$PortalUserToJson(this);

  bool get hasReferrer => referredBy != null;
  bool get hasReferrals => referralCount > 0;
}

@JsonSerializable()
class PortalWalletContext {
  @JsonKey(name: 'address')
  final String address;

  @JsonKey(name: 'isAuthenticatedUser')
  final bool isAuthenticatedUser;

  @JsonKey(name: 'isAdmin')
  final bool isAdmin;

  const PortalWalletContext({
    required this.address,
    required this.isAuthenticatedUser,
    required this.isAdmin,
  });

  factory PortalWalletContext.fromJson(Map<String, dynamic> json) => 
      _$PortalWalletContextFromJson(json);

  Map<String, dynamic> toJson() => _$PortalWalletContextToJson(this);

  String get shortAddress => 
      '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
}

class ProtocolUsage {
  final String name;
  final int daysUsed;

  const ProtocolUsage({
    required this.name,
    required this.daysUsed,
  });

  String get displayName {
    switch (name.toLowerCase()) {
      case 'daily_spin':
        return 'Daily Spin';
      case 'rooster':
        return 'Rooster';
      case 'plume_staking':
        return 'Plume Staking';
      case 'nest':
        return 'Nest';
      case 'predx':
        return 'PredX';
      default:
        return name.split('_').map((word) => 
          word.substring(0, 1).toUpperCase() + word.substring(1)).join(' ');
    }
  }

  String get formattedDays => '$daysUsed days';
}

class PortalStatsException implements Exception {
  final String message;
  final int? statusCode;
  final String? walletAddress;

  const PortalStatsException(
    this.message, {
    this.statusCode,
    this.walletAddress,
  });

  @override
  String toString() => 'PortalStatsException: $message';
}

enum PortalStatsLoadingState {
  idle,
  loading,
  success,
  error,
  empty,
}

class PortalStatsState {
  final PortalStatsLoadingState loadingState;
  final PortalStatsResponse? stats;
  final String? errorMessage;
  final DateTime? lastUpdated;
  final String? currentWalletAddress;

  const PortalStatsState({
    this.loadingState = PortalStatsLoadingState.idle,
    this.stats,
    this.errorMessage,
    this.lastUpdated,
    this.currentWalletAddress,
  });

  PortalStatsState copyWith({
    PortalStatsLoadingState? loadingState,
    PortalStatsResponse? stats,
    String? errorMessage,
    DateTime? lastUpdated,
    String? currentWalletAddress,
  }) {
    return PortalStatsState(
      loadingState: loadingState ?? this.loadingState,
      stats: stats ?? this.stats,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currentWalletAddress: currentWalletAddress ?? this.currentWalletAddress,
    );
  }

  bool get isLoading => loadingState == PortalStatsLoadingState.loading;
  bool get hasData => loadingState == PortalStatsLoadingState.success && stats != null;
  bool get hasError => loadingState == PortalStatsLoadingState.error;
  bool get isEmpty => loadingState == PortalStatsLoadingState.empty;
}
