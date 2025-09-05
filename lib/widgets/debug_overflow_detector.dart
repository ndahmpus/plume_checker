import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class DebugOverflowDetector extends StatefulWidget {
  final Widget child;
  final String? debugName;

  const DebugOverflowDetector({
    Key? key,
    required this.child,
    this.debugName,
  }) : super(key: key);

  @override
  _DebugOverflowDetectorState createState() => _DebugOverflowDetectorState();
}

class _DebugOverflowDetectorState extends State<DebugOverflowDetector> {
  final GlobalKey _key = GlobalKey();
  bool _hasOverflow = false;
  String? _overflowDetails;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkForOverflow());
    }
  }

  void _checkForOverflow() {
    if (!kDebugMode) return;

    try {
      final RenderObject? renderObject = _key.currentContext?.findRenderObject();
      if (renderObject != null) {
        if (renderObject is RenderBox) {
          final RenderBox renderBox = renderObject;
          final Size size = renderBox.size;
          final BoxConstraints? constraints = renderBox.constraints;

          print('🔍 [${widget.debugName ?? 'Widget'}] Size: $size, Constraints: $constraints');

          if (constraints != null) {
            bool hasWidthOverflow = size.width > constraints.maxWidth;
            bool hasHeightOverflow = size.height > constraints.maxHeight;

            if (hasWidthOverflow || hasHeightOverflow) {
              setState(() {
                _hasOverflow = true;
                _overflowDetails = 'Width overflow: $hasWidthOverflow, Height overflow: $hasHeightOverflow';
              });

              print('🚨 [${widget.debugName ?? 'Widget'}] OVERFLOW DETECTED: $_overflowDetails');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error checking overflow: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = KeyedSubtree(
      key: _key,
      child: widget.child,
    );

    if (kDebugMode && _hasOverflow) {
      return Stack(
        children: [
          child,
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'OVERFLOW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return child;
  }
}

extension DebugOverflowExtension on Widget {
  Widget debugOverflow([String? debugName]) {
    if (kDebugMode) {
      return DebugOverflowDetector(
        debugName: debugName,
        child: this,
      );
    }
    return this;
  }
}

class OverflowErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const OverflowErrorWidget({Key? key, required this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.withOpacity(0.8),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            'OVERFLOW ERROR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            details.exception.toString().split('\n').first,
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
