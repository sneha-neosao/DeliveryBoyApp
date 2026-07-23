import 'package:delivery_boy_app/src/configs/injector/injector.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:flutter/material.dart';

/// Shows a custom Toast/SnackBar using an OverlayEntry.
/// This guarantees it will always appear on top of dialogs, bottom sheets, etc.
void appSnackBar(BuildContext context, Color color, String label) {
  OverlayState? overlay;
  try {
    overlay = Overlay.of(context);
  } catch (_) {
    // Overlay lookup failed (e.g. if context is the root Navigator context itself)
  }

  overlay ??= globalNavigator.currentState?.overlay;

  if (overlay == null) {
    return;
  }

  late OverlayEntry entry;
  
  entry = OverlayEntry(
    builder: (context) => _AnimatedOverlaySnackBar(
      color: color,
      label: label,
      onDismissed: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _AnimatedOverlaySnackBar extends StatefulWidget {
  final Color color;
  final String label;
  final VoidCallback onDismissed;

  const _AnimatedOverlaySnackBar({
    required this.color,
    required this.label,
    required this.onDismissed,
  });

  @override
  State<_AnimatedOverlaySnackBar> createState() => _AnimatedOverlaySnackBarState();
}

class _AnimatedOverlaySnackBarState extends State<_AnimatedOverlaySnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Auto dismiss after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismissed();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine bottom padding, taking safe area into account.
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom +
        24.0;

    return Positioned(
      bottom: bottomPadding,
      left: 20.0,
      right: 20.0,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white, // Fixed white background
                borderRadius: BorderRadius.circular(25.0), // Curved like login textfields (radius 25)
                border: Border.all(
                  color: AppColor.darkOrange, // Dark orange border
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Dark orange icon at left side
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColor.darkOrange, // Dark Orange Icon
                    size: 22.0,
                  ),
                  const SizedBox(width: 12.0),
                  // Display message in front of icon
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
