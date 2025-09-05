import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class WalletHistoryItem {
  final String address;
  final DateTime searchedAt;
  final String shortAddress;

  WalletHistoryItem({
    required this.address,
    required this.searchedAt,
  }) : shortAddress = _shortenAddress(address);

  static String _shortenAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'searchedAt': searchedAt.millisecondsSinceEpoch,
    };
  }

  factory WalletHistoryItem.fromJson(Map<String, dynamic> json) {
    return WalletHistoryItem(
      address: json['address'],
      searchedAt: DateTime.fromMillisecondsSinceEpoch(json['searchedAt']),
    );
  }
}

class WalletHistoryService {
  static const int _maxHistoryItems = 10;
  static WalletHistoryService? _instance;

  static WalletHistoryService get instance {
    _instance ??= WalletHistoryService._();
    return _instance!;
  }

  WalletHistoryService._();

  Future<void> addToHistory(String walletAddress) async {
    if (walletAddress.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      history.removeWhere((item) => item.address.toLowerCase() == walletAddress.toLowerCase());

      history.insert(0, WalletHistoryItem(
        address: walletAddress,
        searchedAt: DateTime.now(),
      ));

      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      final jsonList = history.map((item) => item.toJson()).toList();
      await prefs.setString(StorageKeys.walletAddressHistory, jsonEncode(jsonList));
      await prefs.setInt(StorageKeys.walletHistoryLastUpdated, DateTime.now().millisecondsSinceEpoch);

      print('✅ WalletHistory: Added ${WalletHistoryItem._shortenAddress(walletAddress)} to history (${history.length} items total)');
    } catch (e) {
      print('❌ WalletHistory: Failed to add address to history: $e');
    }
  }

  Future<List<WalletHistoryItem>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(StorageKeys.walletAddressHistory);

      if (historyJson == null || historyJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded.map((item) => WalletHistoryItem.fromJson(item)).toList();
    } catch (e) {
      print('❌ WalletHistory: Failed to load history: $e');
      return [];
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.walletAddressHistory);
      await prefs.remove(StorageKeys.walletHistoryLastUpdated);

      print('✅ WalletHistory: History cleared');
    } catch (e) {
      print('❌ WalletHistory: Failed to clear history: $e');
    }
  }

  Future<void> removeFromHistory(String walletAddress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      history.removeWhere((item) => item.address.toLowerCase() == walletAddress.toLowerCase());

      if (history.isEmpty) {
        await prefs.remove(StorageKeys.walletAddressHistory);
        await prefs.remove(StorageKeys.walletHistoryLastUpdated);
      } else {
        final jsonList = history.map((item) => item.toJson()).toList();
        await prefs.setString(StorageKeys.walletAddressHistory, jsonEncode(jsonList));
        await prefs.setInt(StorageKeys.walletHistoryLastUpdated, DateTime.now().millisecondsSinceEpoch);
      }

      print('✅ WalletHistory: Removed ${WalletHistoryItem._shortenAddress(walletAddress)} from history');
    } catch (e) {
      print('❌ WalletHistory: Failed to remove address from history: $e');
    }
  }

  Future<bool> hasHistory() async {
    final history = await getHistory();
    return history.isNotEmpty;
  }

  Future<int> getHistoryCount() async {
    final history = await getHistory();
    return history.length;
  }

  Future<String?> getMostRecentAddress() async {
    final history = await getHistory();
    return history.isNotEmpty ? history.first.address : null;
  }

  Future<DateTime?> getLastUpdated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(StorageKeys.walletHistoryLastUpdated);
      return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
    } catch (e) {
      return null;
    }
  }
}
