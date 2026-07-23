import 'package:flutter/material.dart';

import '../../core/theme/app_font.dart';

class AppAlertDialogWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color confirmBtnColor;
  final VoidCallback onConfirm;
  final bool isLoading;

  const AppAlertDialogWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.confirmText,
    this.cancelText = 'Cancel',
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.confirmBtnColor,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon ───────────────────────────────────────────────
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 32),
                ),

                const SizedBox(height: 20),

                // ── Title ──────────────────────────────────────────────
                Text(
                  title,
                  style: AppFont.style(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0D121F),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Subtitle ───────────────────────────────────────────
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppFont.style(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5C616E),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Buttons ────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF6F6F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            cancelText,
                            style: AppFont.style(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0D121F),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirmBtnColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            confirmText,
                            style: AppFont.style(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Close Icon ─────────────────────────────────────────────
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, size: 20, color: Color(0xFFB0B8C8)),
            ),
          ),
        ],
      ),
    );
  }
}
