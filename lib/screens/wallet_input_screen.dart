import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import 'dart:math' show min;
import '../services/wallet_history_service.dart';
import 'plume_portal_screen.dart';

class WalletInputScreen extends StatefulWidget {
  const WalletInputScreen({super.key});

  @override
  State<WalletInputScreen> createState() => _WalletInputScreenState();
}

class _WalletInputScreenState extends State<WalletInputScreen> {
  final TextEditingController _walletController = TextEditingController();
  final FocusNode _walletFocusNode = FocusNode();

  List<WalletHistoryItem> _walletHistory = [];
  bool _isLoadingHistory = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadWalletHistory();
  }

  @override
  void dispose() {
    _walletController.dispose();
    _walletFocusNode.dispose();
    super.dispose();
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
      print('Failed to load wallet history: $e');
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
      print('Failed to save to history: $e');
    }
  }

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
      print('Failed to clear history: $e');
    }
  }

  Future<void> _removeFromHistory(String address) async {
    try {
      await WalletHistoryService.instance.removeFromHistory(address);
      await _loadWalletHistory();
    } catch (e) {
      print('Failed to remove from history: $e');
    }
  }

  Future<void> _navigateToPortal(String walletAddress) async {
    if (_isProcessing || walletAddress.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    if (!_isValidWalletAddress(walletAddress.trim())) {
      _showErrorSnackBar('Please enter a valid wallet address');
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      final trimmedAddress = walletAddress.trim();

      await _saveToHistory(trimmedAddress);

      if (mounted) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return PlumePortalScreen(
                walletAddress: trimmedAddress,
              );
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    } catch (e) {
      print('Navigation error: $e');
      _showErrorSnackBar('Failed to navigate to portal');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  bool _isValidWalletAddress(String address) {
    return address.isNotEmpty && 
           address.startsWith('0x') && 
           address.length >= 40;
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0B0F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildAnimatedBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  _buildHeader(),

                  const SizedBox(height: 24),

                  _buildInputSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 40,
        color: Colors.transparent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'v.1.0.0 Copyright by NDA',
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildFuturisticLogo(),

          const SizedBox(height: 12),

          Text(
            'Enter your wallet address to check Plume Portal stats and data',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFuturisticLogo() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.6),
            const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            const Color(0xFF06B6D4).withValues(alpha: 0.3),
            const Color(0xFF10B981).withValues(alpha: 0.4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0B0F).withValues(alpha: 0.9),
              const Color(0xFF1E1E1E).withValues(alpha: 0.6),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                        const Color(0xFF06B6D4),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'PLUME PORTAL',
                      style: AppFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        const Color(0xFF06B6D4),
                        const Color(0xFF10B981),
                        const Color(0xFF6366F1),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'CHECKER STATS',
                      style: AppFonts.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            _buildCornerDecorations(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _walletController,
            focusNode: _walletFocusNode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Courier',
            ),
            decoration: InputDecoration(
              labelText: 'Wallet Address',
              labelStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              hintText: '0x1234...abcd',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontFamily: 'Courier',
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF06B6D4),
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                Icons.account_balance_wallet,
                color: Colors.white.withValues(alpha: 0.7),
                size: 20,
              ),
              suffixIcon: _walletController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      onPressed: () {
                        _walletController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
            onSubmitted: (value) {
              final trimmedValue = value.trim();
              if (trimmedValue.isNotEmpty) {
                _navigateToPortal(trimmedValue);
              }
            },
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: (_walletController.text.trim().isNotEmpty && !_isProcessing)
                  ? () {
                      final address = _walletController.text.trim();
                      if (address.isNotEmpty) {
                        _navigateToPortal(address);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: (_walletController.text.trim().isNotEmpty && !_isProcessing)
                    ? const Color(0xFF6366F1)
                    : Colors.grey.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor: Colors.grey.shade800,
                disabledForegroundColor: Colors.grey.shade500,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Check Portal Stats',
                          style: AppFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          _buildWalletHistorySection(),
        ],
      ),
    );
  }

  Widget _buildWalletHistorySection() {
    if (_isLoadingHistory) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_walletHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No wallet history yet',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: Colors.white.withValues(alpha: 0.7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Recent Wallets',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (_walletHistory.isNotEmpty)
              IconButton(
                onPressed: _clearAllHistory,
                icon: Icon(
                  Icons.clear_all,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 16,
                ),
                tooltip: 'Clear all history',
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(
          min(_walletHistory.length, 3),
          (index) {
            final item = _walletHistory[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  _walletController.text = item.address;
                  setState(() {});
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _shortenAddress(item.address),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeFromHistory(item.address),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withValues(alpha: 0.4),
                          size: 16,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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

  Widget _buildCornerDecorations() {
    return Stack(
      children: [
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.6),
                  width: 2,
                ),
                left: BorderSide(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                  width: 2,
                ),
                right: BorderSide(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.6),
                  width: 2,
                ),
                left: BorderSide(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF10B981).withValues(alpha: 0.6),
                  width: 2,
                ),
                right: BorderSide(
                  color: const Color(0xFF10B981).withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
