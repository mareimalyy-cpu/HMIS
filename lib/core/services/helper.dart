import 'dart:ui';

import 'package:flutter/material.dart';


/// Glassy toast notification that slides in from the top as an overlay.
///
/// NOTES:
/// - Uses Overlay instead of SnackBar for true top-positioned display
/// - Reusable across the app — works from any context (pages, dialogs, bottom sheets)
/// - Auto-dismisses after [duration], with slide + fade animation
/// - Only one toast visible at a time (previous is dismissed instantly)
class GlassySnackbar {
  static OverlayEntry? _currentEntry;
  static _GlassyOverlayState? _currentState;

  /// Show glassy toast from the top.
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.error,
    Duration duration = const Duration(seconds: 3),
  }) {
    _dismiss();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _GlassyOverlay(
        message: message,
        type: type,
        duration: duration,
        onDismissed: () {
          entry.remove();
          if (_currentEntry == entry) {
            _currentEntry = null;
            _currentState = null;
          }
        },
        onStateCreated: (state) => _currentState = state,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void _dismiss() {
    if (_currentState != null) {
      _currentState!.dismissImmediately();
    } else if (_currentEntry != null) {
      _currentEntry!.remove();
    }
    _currentEntry = null;
    _currentState = null;
  }

  static void showError(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.error);

  static void showSuccess(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.success);

  static void showInfo(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.info);

  static void showGlobal({
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final ctx = WidgetsBinding.instance.focusManager.primaryFocus?.context;
    if (ctx != null) {
      show(ctx, message: message, type: type, duration: duration);
    }
  }
}

/// Snackbar type enum
enum SnackbarType { error, success, info }

/// Extension on SnackbarType for colors and icons
extension SnackbarTypeX on SnackbarType {
  Color get color {
    switch (this) {
      case SnackbarType.error:
        return const Color(0xFFFF6B6B);
      case SnackbarType.success:
        return const Color(0xFF51CF66);
      case SnackbarType.info:
        return const Color(0xFF339AF0);
    }
  }

  IconData get icon {
    switch (this) {
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.info:
        return Icons.info_outline;
    }
  }
}

// =============================================================================
// OVERLAY WIDGET — slide-down animation + auto-dismiss
// =============================================================================

class _GlassyOverlay extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final Duration duration;
  final VoidCallback onDismissed;
  final void Function(_GlassyOverlayState state) onStateCreated;

  const _GlassyOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
    required this.onStateCreated,
  });

  @override
  State<_GlassyOverlay> createState() => _GlassyOverlayState();
}

class _GlassyOverlayState extends State<_GlassyOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    widget.onStateCreated(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) {
      Future.delayed(widget.duration, () {
        if (mounted) _dismissAnimated();
      });
    });
  }

  void _dismissAnimated() {
    _controller.reverse().then((_) {
      if (mounted) widget.onDismissed();
    });
  }

  void dismissImmediately() {
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, topPadding + 8, 12, 0),
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < -100) {
                  _dismissAnimated();
                }
              },
              child: _GlassySnackbarContent(
                message: widget.message,
                type: widget.type,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CONTENT — glassy card with blur
// =============================================================================

class _GlassySnackbarContent extends StatelessWidget {
  final String message;
  final SnackbarType type;

  const _GlassySnackbarContent({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: type.color.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: type.color.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: type.color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(type.icon, color: type.color, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
