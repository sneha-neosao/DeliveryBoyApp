import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'safe_gif_controller.dart';

/// A full-screen blurred overlay with the loader.gif playing in a circle.
/// Drop this on top of any widget using a Stack.
class GifLoaderOverlay extends StatefulWidget {
  const GifLoaderOverlay({super.key});

  @override
  State<GifLoaderOverlay> createState() => _GifLoaderOverlayState();
}

class _GifLoaderOverlayState extends State<GifLoaderOverlay> {
  late final SafeGifController _gifController;

  @override
  void initState() {
    super.initState();
    _gifController = SafeGifController(loop: true);
  }

  @override
  void dispose() {
    _gifController.pause();
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Blurred backdrop ────────────────────────────────────────────
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ),
        ),

        // ── Centred GIF in a circle ─────────────────────────────────────
        Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: GifView.asset(
                'assets/gif/loader.gif',
                controller: _gifController,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
