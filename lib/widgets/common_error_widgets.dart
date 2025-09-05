import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ErrorWidgetType {
  warning,
  error,
  empty,
  info,
}

class UnifiedStateWidget extends StatelessWidget {
  final ErrorWidgetType type;
  final String title;
  final String message;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool showLoading;
  final double? height;

  const UnifiedStateWidget({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionLabel,
    this.showLoading = false,
    this.height,
  });

  factory UnifiedStateWidget.warning({
    required String title,
    required String message,
    String? subtitle,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
    double? height,
  }) {
    return UnifiedStateWidget(
      type: ErrorWidgetType.warning,
      title: title,
      message: message,
      subtitle: subtitle,
      icon: icon ?? Icons.warning_rounded,
      onAction: onAction,
      actionLabel: actionLabel,
      height: height,
    );
  }

  factory UnifiedStateWidget.error({
    required String title,
    required String message,
    String? subtitle,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
    double? height,
  }) {
    return UnifiedStateWidget(
      type: ErrorWidgetType.error,
      title: title,
      message: message,
      subtitle: subtitle,
      icon: icon ?? Icons.error_rounded,
      onAction: onAction,
      actionLabel: actionLabel ?? 'Retry',
      height: height,
    );
  }

  factory UnifiedStateWidget.empty({
    required String title,
    required String message,
    String? subtitle,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
    double? height,
  }) {
    return UnifiedStateWidget(
      type: ErrorWidgetType.empty,
      title: title,
      message: message,
      subtitle: subtitle,
      icon: icon ?? Icons.inbox_outlined,
      onAction: onAction,
      actionLabel: actionLabel ?? 'Refresh',
      height: height,
    );
  }

  factory UnifiedStateWidget.loading({
    required String title,
    String? message,
    double? height,
  }) {
    return UnifiedStateWidget(
      type: ErrorWidgetType.info,
      title: title,
      message: message ?? 'Please wait...',
      showLoading: true,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    final bool isCompact = height != null && height! < 120;
    final iconSize = isCompact ? 16.0 : 24.0;
    final titleSize = isCompact ? 12.0 : 14.0;
    final messageSize = isCompact ? 10.0 : 12.0;
    final subtitleSize = isCompact ? 9.0 : 10.0;

    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 10 : 12),
            decoration: BoxDecoration(
              color: colors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.border,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: showLoading
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    ),
                  )
                : Icon(
                    icon!,
                    color: colors.primary,
                    size: iconSize,
                  ),
          ),

          SizedBox(height: isCompact ? 8 : 12),

          Flexible(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(height: isCompact ? 2 : 4),

          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: messageSize,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (subtitle != null) ...[
            SizedBox(height: isCompact ? 2 : 4),
            Flexible(
              child: Text(
                subtitle!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: subtitleSize,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          if (onAction != null && actionLabel != null && !showLoading) ...[
            SizedBox(height: isCompact ? 8 : 12),
            Flexible(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onAction!();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 8 : 12,
                      vertical: isCompact ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1),
                          const Color(0xFF8B5CF6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: isCompact ? 12 : 14,
                        ),
                        SizedBox(width: isCompact ? 4 : 6),
                        Text(
                          actionLabel!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isCompact ? 10 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (height != null) {
      content = SizedBox(
        height: height,
        child: content,
      );
    }

    return Container(
      padding: EdgeInsets.all(height != null && height! < 120 ? 12 : 20),
      decoration: BoxDecoration(
        color: colors.containerBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.containerBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.containerShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: content,
    );
  }

  _StateColors _getColors() {
    switch (type) {
      case ErrorWidgetType.warning:
        return _StateColors(
          primary: Colors.orange.withValues(alpha: 0.8),
          background: Colors.orange.withValues(alpha: 0.2),
          border: Colors.orange.withValues(alpha: 0.4),
          shadow: Colors.orange.withValues(alpha: 0.15),
          containerBackground: Colors.orange.withValues(alpha: 0.1),
          containerBorder: Colors.orange.withValues(alpha: 0.3),
          containerShadow: Colors.orange.withValues(alpha: 0.1),
        );

      case ErrorWidgetType.error:
        return _StateColors(
          primary: Colors.red.withValues(alpha: 0.9),
          background: Colors.red.withValues(alpha: 0.2),
          border: Colors.red.withValues(alpha: 0.4),
          shadow: Colors.red.withValues(alpha: 0.15),
          containerBackground: Colors.red.withValues(alpha: 0.1),
          containerBorder: Colors.red.withValues(alpha: 0.3),
          containerShadow: Colors.red.withValues(alpha: 0.1),
        );

      case ErrorWidgetType.empty:
        return _StateColors(
          primary: Colors.blue.withValues(alpha: 0.8),
          background: Colors.blue.withValues(alpha: 0.2),
          border: Colors.blue.withValues(alpha: 0.4),
          shadow: Colors.blue.withValues(alpha: 0.15),
          containerBackground: Colors.blue.withValues(alpha: 0.1),
          containerBorder: Colors.blue.withValues(alpha: 0.3),
          containerShadow: Colors.blue.withValues(alpha: 0.1),
        );

      case ErrorWidgetType.info:
      default:
        return _StateColors(
          primary: const Color(0xFF6366F1),
          background: const Color(0xFF6366F1).withValues(alpha: 0.2),
          border: const Color(0xFF6366F1).withValues(alpha: 0.3),
          shadow: const Color(0xFF6366F1).withValues(alpha: 0.15),
          containerBackground: Colors.white.withValues(alpha: 0.05),
          containerBorder: Colors.white.withValues(alpha: 0.1),
          containerShadow: Colors.black.withValues(alpha: 0.1),
        );
    }
  }
}

class _StateColors {
  final Color primary;
  final Color background;
  final Color border;
  final Color shadow;
  final Color containerBackground;
  final Color containerBorder;
  final Color containerShadow;

  const _StateColors({
    required this.primary,
    required this.background,
    required this.border,
    required this.shadow,
    required this.containerBackground,
    required this.containerBorder,
    required this.containerShadow,
  });
}

class WalletStateWidget extends StatelessWidget {
  final String state;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final double? height;

  const WalletStateWidget({
    super.key,
    required this.state,
    this.errorMessage,
    this.onRetry,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    final double constrainedHeight = height ?? 100;

    Widget content;

    switch (state) {
      case 'loading':
        content = UnifiedStateWidget.loading(
          title: 'Loading Assets...',
          message: 'Fetching wallet balance',
          height: constrainedHeight,
        );
        break;

      case 'noData':
        content = UnifiedStateWidget.warning(
          title: 'No Assets Found',
          message: 'No wallet data available',
          icon: Icons.warning_rounded,
          height: constrainedHeight,
        );
        break;

      case 'empty':
        content = UnifiedStateWidget.empty(
          title: 'Empty Wallet',
          message: 'No assets detected',
          icon: Icons.account_balance_wallet_outlined,
          onAction: onRetry,
          actionLabel: 'Check Again',
          height: constrainedHeight,
        );
        break;

      case 'error':
        content = UnifiedStateWidget.error(
          title: 'Asset Load Failed',
          message: 'Unable to load assets',
          subtitle: errorMessage,
          icon: Icons.error_rounded,
          onAction: onRetry,
          actionLabel: 'Retry',
          height: constrainedHeight,
        );
        break;

      default:
        content = UnifiedStateWidget.warning(
          title: 'Unknown State',
          message: 'Unexpected state: $state',
          height: constrainedHeight,
        );
        break;
    }

    return SizedBox(
      height: constrainedHeight,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight,
              minHeight: 0,
            ),
            child: content,
          );
        },
      ),
    );
  }
}

class PortfolioStateWidget extends StatelessWidget {
  final String state;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? walletAddress;

  const PortfolioStateWidget({
    super.key,
    required this.state,
    this.errorMessage,
    this.onRetry,
    this.walletAddress,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case 'loading':
        return UnifiedStateWidget.loading(
          title: 'Loading Portfolio...',
          message: 'Fetching holdings and calculating analytics',
        );

      case 'empty':
        return UnifiedStateWidget.empty(
          title: 'Empty Portfolio',
          message: 'No holdings detected',
          subtitle: walletAddress != null 
              ? 'Wallet: ${_shortenAddress(walletAddress!)}'
              : 'This wallet has no token holdings',
          icon: Icons.account_balance_wallet_outlined,
          onAction: onRetry,
          actionLabel: 'Refresh Portfolio',
        );

      case 'error':
        return UnifiedStateWidget.error(
          title: 'Portfolio Load Failed',
          message: 'Unable to load portfolio data',
          subtitle: errorMessage ?? 'Please try again',
          icon: Icons.error_rounded,
          onAction: onRetry,
          actionLabel: 'Retry Loading',
        );

      default:
        return UnifiedStateWidget.warning(
          title: 'Unknown Portfolio State',
          message: 'Unexpected portfolio state: $state',
        );
    }
  }

  String _shortenAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}

class CompactStateWidget extends StatelessWidget {
  final ErrorWidgetType type;
  final String message;
  final IconData? icon;
  final bool showLoading;

  const CompactStateWidget({
    super.key,
    required this.type,
    required this.message,
    this.icon,
    this.showLoading = false,
  });

  factory CompactStateWidget.loading(String message) {
    return CompactStateWidget(
      type: ErrorWidgetType.info,
      message: message,
      showLoading: true,
    );
  }

  factory CompactStateWidget.warning(String message, {IconData? icon}) {
    return CompactStateWidget(
      type: ErrorWidgetType.warning,
      message: message,
      icon: icon ?? Icons.warning_rounded,
    );
  }

  factory CompactStateWidget.error(String message, {IconData? icon}) {
    return CompactStateWidget(
      type: ErrorWidgetType.error,
      message: message,
      icon: icon ?? Icons.error_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.containerBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.containerBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLoading)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            )
          else if (icon != null)
            Icon(
              icon!,
              color: colors.primary,
              size: 14,
            ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  _StateColors _getColors() {
    switch (type) {
      case ErrorWidgetType.warning:
        return _StateColors(
          primary: Colors.orange.withValues(alpha: 0.8),
          background: Colors.orange.withValues(alpha: 0.2),
          border: Colors.orange.withValues(alpha: 0.4),
          shadow: Colors.orange.withValues(alpha: 0.15),
          containerBackground: Colors.orange.withValues(alpha: 0.1),
          containerBorder: Colors.orange.withValues(alpha: 0.3),
          containerShadow: Colors.orange.withValues(alpha: 0.1),
        );

      case ErrorWidgetType.error:
        return _StateColors(
          primary: Colors.red.withValues(alpha: 0.9),
          background: Colors.red.withValues(alpha: 0.2),
          border: Colors.red.withValues(alpha: 0.4),
          shadow: Colors.red.withValues(alpha: 0.15),
          containerBackground: Colors.red.withValues(alpha: 0.1),
          containerBorder: Colors.red.withValues(alpha: 0.3),
          containerShadow: Colors.red.withValues(alpha: 0.1),
        );

      case ErrorWidgetType.empty:
        return _StateColors(
          primary: Colors.blue.withValues(alpha: 0.8),
          background: Colors.blue.withValues(alpha: 0.2),
          border: Colors.blue.withValues(alpha: 0.4),
          shadow: Colors.blue.withValues(alpha: 0.15),
          containerBackground: Colors.blue.withValues(alpha: 0.1),
          containerBorder: Colors.blue.withValues(alpha: 0.3),
          containerShadow: Colors.blue.withValues(alpha: 0.1),
        );

      case ErrorWidgetType.info:
      default:
        return _StateColors(
          primary: const Color(0xFF6366F1),
          background: const Color(0xFF6366F1).withValues(alpha: 0.2),
          border: const Color(0xFF6366F1).withValues(alpha: 0.3),
          shadow: const Color(0xFF6366F1).withValues(alpha: 0.15),
          containerBackground: Colors.white.withValues(alpha: 0.05),
          containerBorder: Colors.white.withValues(alpha: 0.1),
          containerShadow: Colors.black.withValues(alpha: 0.1),
        );
    }
  }
}
