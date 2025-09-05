class Season1AllocationResponse {
  final Season1AllocationData data;

  const Season1AllocationResponse({
    required this.data,
  });

  factory Season1AllocationResponse.fromJson(Map<String, dynamic> json) {
    return Season1AllocationResponse(
      data: Season1AllocationData.fromJson(json['data'] ?? json),
    );
  }
}

class Season1AllocationData {
  final Season1Allocation seasonOneAllocation;
  final WalletInfo walletContext;

  const Season1AllocationData({
    required this.seasonOneAllocation,
    required this.walletContext,
  });

  factory Season1AllocationData.fromJson(Map<String, dynamic> json) {
    return Season1AllocationData(
      seasonOneAllocation: Season1Allocation.fromJson(json['seasonOneAllocation'] ?? {}),
      walletContext: WalletInfo.fromJson(json['walletContext'] ?? json),
    );
  }
}

class WalletInfo {
  final String address;
  final bool isAuthenticatedUser;
  final bool isAdmin;

  const WalletInfo({
    required this.address,
    required this.isAuthenticatedUser,
    required this.isAdmin,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      address: json['address'] as String? ?? '',
      isAuthenticatedUser: json['isAuthenticatedUser'] as bool? ?? false,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
  }
}

class Season1Allocation {
  final double totalAllocation;
  final double claimedAmount;
  final double remainingAmount;
  final String allocationStatus;
  final String eligibilityTier;
  final DateTime? allocationDate;
  final DateTime? expirationDate;
  final List<AllocationDetail> allocationDetails;
  final AllocationStats stats;

  const Season1Allocation({
    required this.totalAllocation,
    required this.claimedAmount,
    required this.remainingAmount,
    required this.allocationStatus,
    required this.eligibilityTier,
    this.allocationDate,
    this.expirationDate,
    required this.allocationDetails,
    required this.stats,
  });

  factory Season1Allocation.fromJson(Map<String, dynamic> json) {
    return Season1Allocation(
      totalAllocation: _parseDouble(json['totalAllocation']) ?? 0.0,
      claimedAmount: _parseDouble(json['claimedAmount']) ?? 0.0,
      remainingAmount: _parseDouble(json['remainingAmount']) ?? 0.0,
      allocationStatus: json['allocationStatus'] as String? ?? 'unknown',
      eligibilityTier: json['eligibilityTier'] as String? ?? 'none',
      allocationDate: _parseDateTime(json['allocationDate']),
      expirationDate: _parseDateTime(json['expirationDate']),
      allocationDetails: (json['allocationDetails'] as List?)
          ?.map((item) => AllocationDetail.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      stats: AllocationStats.fromJson(json['stats'] ?? {}),
    );
  }

  bool get hasAllocation => totalAllocation > 0;
  bool get isActive => allocationStatus.toLowerCase() == 'active';
  bool get isExpired => expirationDate != null && DateTime.now().isAfter(expirationDate!);
  bool get hasClaimed => claimedAmount > 0;

  double get claimPercentage => totalAllocation > 0 ? (claimedAmount / totalAllocation) * 100 : 0;
  double get remainingPercentage => totalAllocation > 0 ? (remainingAmount / totalAllocation) * 100 : 0;

  String get formattedTotalAllocation => _formatAllocation(totalAllocation);
  String get formattedClaimedAmount => _formatAllocation(claimedAmount);
  String get formattedRemainingAmount => _formatAllocation(remainingAmount);
  String get formattedClaimPercentage => '${claimPercentage.toStringAsFixed(1)}%';
  String get formattedRemainingPercentage => '${remainingPercentage.toStringAsFixed(1)}%';

  String get statusDisplay => _getStatusDisplay();
  String get tierDisplay => _getTierDisplay();

  String _formatAllocation(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M PLUME';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K PLUME';
    } else if (amount >= 1) {
      return '${amount.toStringAsFixed(2)} PLUME';
    } else {
      return '${amount.toStringAsFixed(6)} PLUME';
    }
  }

  String _getStatusDisplay() {
    switch (allocationStatus.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'claimed':
        return 'Fully Claimed';
      case 'expired':
        return 'Expired';
      case 'pending':
        return 'Pending';
      case 'not_available':
        return 'Not Available';
      case 'none':
        return 'No Allocation';
      case 'estimated':
        return 'Estimated';
      default:
        return 'Unknown';
    }
  }

  String _getTierDisplay() {
    switch (eligibilityTier.toLowerCase()) {
      case 'diamond':
        return 'Diamond Tier';
      case 'platinum':
        return 'Platinum Tier';
      case 'gold':
        return 'Gold Tier';
      case 'silver':
        return 'Silver Tier';
      case 'bronze':
        return 'Bronze Tier';
      default:
        return 'Standard';
    }
  }
}

class AllocationDetail {
  final String category;
  final double amount;
  final String description;
  final String status;
  final DateTime? unlockDate;

  const AllocationDetail({
    required this.category,
    required this.amount,
    required this.description,
    required this.status,
    this.unlockDate,
  });

  factory AllocationDetail.fromJson(Map<String, dynamic> json) {
    return AllocationDetail(
      category: json['category'] as String? ?? '',
      amount: _parseDouble(json['amount']) ?? 0.0,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      unlockDate: _parseDateTime(json['unlockDate']),
    );
  }

  String get formattedAmount => _formatAmount(amount);
  bool get isUnlocked => unlockDate == null || DateTime.now().isAfter(unlockDate!);
  bool get isClaimed => status.toLowerCase() == 'claimed';

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}

class AllocationStats {
  final int totalEligibleUsers;
  final double totalPoolSize;
  final double averageAllocation;
  final String distributionPhase;

  const AllocationStats({
    required this.totalEligibleUsers,
    required this.totalPoolSize,
    required this.averageAllocation,
    required this.distributionPhase,
  });

  factory AllocationStats.fromJson(Map<String, dynamic> json) {
    return AllocationStats(
      totalEligibleUsers: _parseInt(json['totalEligibleUsers']) ?? 0,
      totalPoolSize: _parseDouble(json['totalPoolSize']) ?? 0.0,
      averageAllocation: _parseDouble(json['averageAllocation']) ?? 0.0,
      distributionPhase: json['distributionPhase'] as String? ?? 'unknown',
    );
  }

  String get formattedTotalPool => _formatNumber(totalPoolSize);
  String get formattedAverageAllocation => _formatNumber(averageAllocation);
  String get formattedTotalUsers => _formatUsers(totalEligibleUsers);

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M PLUME';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K PLUME';
    } else {
      return '${number.toStringAsFixed(2)} PLUME';
    }
  }

  String _formatUsers(int users) {
    if (users >= 1000000) {
      return '${(users / 1000000).toStringAsFixed(1)}M';
    } else if (users >= 1000) {
      return '${(users / 1000).toStringAsFixed(1)}K';
    } else {
      return users.toString();
    }
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
