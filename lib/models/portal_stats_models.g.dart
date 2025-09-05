part of 'portal_stats_models.dart';

PortalStatsResponse _$PortalStatsResponseFromJson(Map<String, dynamic> json) =>
    PortalStatsResponse(
      data: PortalStatsData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PortalStatsResponseToJson(
  PortalStatsResponse instance,
) => <String, dynamic>{'data': instance.data};

PortalStatsData _$PortalStatsDataFromJson(Map<String, dynamic> json) =>
    PortalStatsData(
      walletAddress: json['walletAddress'] as String,
      stats: WalletStats.fromJson(json['stats'] as Map<String, dynamic>),
      walletContext: PortalWalletContext.fromJson(
        json['walletContext'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PortalStatsDataToJson(PortalStatsData instance) =>
    <String, dynamic>{
      'walletAddress': instance.walletAddress,
      'stats': instance.stats,
      'walletContext': instance.walletContext,
    };

WalletStats _$WalletStatsFromJson(Map<String, dynamic> json) => WalletStats(
  walletAddress: json['walletAddress'] as String,
  bridgedTotal: (json['bridgedTotal'] as num).toDouble(),
  swapVolume: (json['swapVolume'] as num).toDouble(),
  swapCount: (json['swapCount'] as num).toInt(),
  tvlTotalUsd: (json['tvlTotalUsd'] as num).toDouble(),
  protocolsUsed: (json['protocolsUsed'] as num).toInt(),
  totalXp: (json['totalXp'] as num).toInt(),
  dateStr: json['dateStr'] as String,
  currentTvlLevels: json['currentTvlLevels'] as String,
  longestTvlStreak: (json['longestTvlStreak'] as num).toInt(),
  plumeStaked: (json['plumeStaked'] as num).toDouble(),
  plumeStakingStreak: (json['plumeStakingStreak'] as num).toInt(),
  plumeStakingClaimedAmount: PlumeStakingClaimed.fromJson(
    json['plumeStakingClaimedAmount'] as Map<String, dynamic>,
  ),
  tvl: (json['TVL'] as num).toDouble(),
  referrals: (json['referrals'] as num).toInt(),
  referredBy: json['referredBy'] as String?,
  referralCode: json['referralCode'] as String,
  referredByUser: json['referredByUser'] as String?,
  completedQuests: (json['completedQuests'] as num).toInt(),
  dailySpinStreak: (json['dailySpinStreak'] as num).toInt(),
  plumeRewards: PlumeRewards.fromJson(
    json['plumeRewards'] as Map<String, dynamic>,
  ),
  bgRank: (json['bgRank'] as num?)?.toInt(),
  realTvlUsd: (json['realTvlUsd'] as num).toDouble(),
  longestSwapStreakWeeks: (json['longestSwapStreakWeeks'] as num).toInt(),
  adjustmentPoints: (json['adjustmentPoints'] as num).toInt(),
  protectorsOfPlumePoints: (json['protectorsOfPlumePoints'] as num).toInt(),
  badgePoints: (json['badgePoints'] as num).toInt(),
  userSelfXp: (json['userSelfXp'] as num).toInt(),
  referralBonusXp: (json['referralBonusXp'] as num).toInt(),
  xpRank: (json['xpRank'] as num).toInt(),
  protocol1: json['protocol1'] as String,
  daysUsed1: (json['daysUsed1'] as num).toInt(),
  protocol2: json['protocol2'] as String,
  daysUsed2: (json['daysUsed2'] as num).toInt(),
  protocol3: json['protocol3'] as String,
  daysUsed3: (json['daysUsed3'] as num).toInt(),
  plumeStakingLongestStreakDays: (json['plumeStakingLongestStreakDays'] as num)
      .toInt(),
  currentPlumeStakingTotalTokens:
      (json['currentPlumeStakingTotalTokens'] as num).toDouble(),
  referralCount: (json['referralCount'] as num).toInt(),
  everActiveSnapshot: json['everActiveSnapshot'] as bool,
  plumeStakingPointsEarned: (json['plumeStakingPointsEarned'] as num).toInt(),
  plumeStakingBonusPointsEarned: (json['plumeStakingBonusPointsEarned'] as num)
      .toInt(),
  battleGroup: (json['battleGroup'] as num).toInt(),
  walletTvl: WalletTvl.fromJson(json['walletTvl'] as Map<String, dynamic>),
  user: PortalUser.fromJson(json['user'] as Map<String, dynamic>),
  totalPnl: (json['totalPnl'] as num).toDouble(),
  winRate: (json['winRate'] as num).toDouble(),
  totalRewards: (json['totalRewards'] as num).toDouble(),
);

Map<String, dynamic> _$WalletStatsToJson(WalletStats instance) =>
    <String, dynamic>{
      'walletAddress': instance.walletAddress,
      'bridgedTotal': instance.bridgedTotal,
      'swapVolume': instance.swapVolume,
      'swapCount': instance.swapCount,
      'tvlTotalUsd': instance.tvlTotalUsd,
      'protocolsUsed': instance.protocolsUsed,
      'totalXp': instance.totalXp,
      'dateStr': instance.dateStr,
      'currentTvlLevels': instance.currentTvlLevels,
      'longestTvlStreak': instance.longestTvlStreak,
      'plumeStaked': instance.plumeStaked,
      'plumeStakingStreak': instance.plumeStakingStreak,
      'plumeStakingClaimedAmount': instance.plumeStakingClaimedAmount,
      'TVL': instance.tvl,
      'referrals': instance.referrals,
      'referredBy': instance.referredBy,
      'referralCode': instance.referralCode,
      'referredByUser': instance.referredByUser,
      'completedQuests': instance.completedQuests,
      'dailySpinStreak': instance.dailySpinStreak,
      'plumeRewards': instance.plumeRewards,
      'bgRank': instance.bgRank,
      'realTvlUsd': instance.realTvlUsd,
      'longestSwapStreakWeeks': instance.longestSwapStreakWeeks,
      'adjustmentPoints': instance.adjustmentPoints,
      'protectorsOfPlumePoints': instance.protectorsOfPlumePoints,
      'badgePoints': instance.badgePoints,
      'userSelfXp': instance.userSelfXp,
      'referralBonusXp': instance.referralBonusXp,
      'xpRank': instance.xpRank,
      'protocol1': instance.protocol1,
      'daysUsed1': instance.daysUsed1,
      'protocol2': instance.protocol2,
      'daysUsed2': instance.daysUsed2,
      'protocol3': instance.protocol3,
      'daysUsed3': instance.daysUsed3,
      'plumeStakingLongestStreakDays': instance.plumeStakingLongestStreakDays,
      'currentPlumeStakingTotalTokens': instance.currentPlumeStakingTotalTokens,
      'referralCount': instance.referralCount,
      'everActiveSnapshot': instance.everActiveSnapshot,
      'plumeStakingPointsEarned': instance.plumeStakingPointsEarned,
      'plumeStakingBonusPointsEarned': instance.plumeStakingBonusPointsEarned,
      'battleGroup': instance.battleGroup,
      'walletTvl': instance.walletTvl,
      'user': instance.user,
      'totalPnl': instance.totalPnl,
      'winRate': instance.winRate,
      'totalRewards': instance.totalRewards,
    };

PlumeStakingClaimed _$PlumeStakingClaimedFromJson(Map<String, dynamic> json) =>
    PlumeStakingClaimed(
      plume: (json['plume'] as num).toDouble(),
      usdc: (json['usdc'] as num).toDouble(),
    );

Map<String, dynamic> _$PlumeStakingClaimedToJson(
  PlumeStakingClaimed instance,
) => <String, dynamic>{'plume': instance.plume, 'usdc': instance.usdc};

PlumeRewards _$PlumeRewardsFromJson(Map<String, dynamic> json) => PlumeRewards(
  spin: (json['spin'] as num).toInt(),
  staking: (json['staking'] as num).toInt(),
  royco: (json['royco'] as num).toInt(),
  merkl: (json['merkl'] as num).toInt(),
);

Map<String, dynamic> _$PlumeRewardsToJson(PlumeRewards instance) =>
    <String, dynamic>{
      'spin': instance.spin,
      'staking': instance.staking,
      'royco': instance.royco,
      'merkl': instance.merkl,
    };

WalletTvl _$WalletTvlFromJson(Map<String, dynamic> json) => WalletTvl(
  walletAddress: json['walletAddress'] as String,
  tvlUsd: (json['tvlUsd'] as num).toDouble(),
);

Map<String, dynamic> _$WalletTvlToJson(WalletTvl instance) => <String, dynamic>{
  'walletAddress': instance.walletAddress,
  'tvlUsd': instance.tvlUsd,
};

PortalUser _$PortalUserFromJson(Map<String, dynamic> json) => PortalUser(
  referralCount: (json['referralCount'] as num).toInt(),
  referredBy: json['referredBy'] as String?,
  referralCode: json['referralCode'] as String,
  referredByUser: json['referredByUser'] as String?,
);

Map<String, dynamic> _$PortalUserToJson(PortalUser instance) =>
    <String, dynamic>{
      'referralCount': instance.referralCount,
      'referredBy': instance.referredBy,
      'referralCode': instance.referralCode,
      'referredByUser': instance.referredByUser,
    };

PortalWalletContext _$PortalWalletContextFromJson(Map<String, dynamic> json) =>
    PortalWalletContext(
      address: json['address'] as String,
      isAuthenticatedUser: json['isAuthenticatedUser'] as bool,
      isAdmin: json['isAdmin'] as bool,
    );

Map<String, dynamic> _$PortalWalletContextToJson(
  PortalWalletContext instance,
) => <String, dynamic>{
  'address': instance.address,
  'isAuthenticatedUser': instance.isAuthenticatedUser,
  'isAdmin': instance.isAdmin,
};
