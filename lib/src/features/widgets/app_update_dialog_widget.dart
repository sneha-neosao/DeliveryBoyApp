import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_color.dart';
import '../../core/theme/app_font.dart';
import '../../core/utils/logger.dart';
import '../../remote/models/version_model/app_update_response.dart';

class AppUpdateDialogWidget extends StatelessWidget {
  final AppVersion appVersion;
  final String currentVersion;
  final VoidCallback? onCancel;

  const AppUpdateDialogWidget({
    super.key,
    required this.appVersion,
    required this.currentVersion,
    this.onCancel,
  });

  static bool _isDialogOpen = false;

  /// Compares current installed version with version returned by the API.
  /// Returns true if they differ, false otherwise.
  static bool isVersionDifferent(String currentVersion, String apiVersion) {
    final cleanCurrent = currentVersion.trim().replaceAll(RegExp(r'^[vV]'), '');
    final cleanApi = apiVersion.trim().replaceAll(RegExp(r'^[vV]'), '');
    if (cleanApi.isEmpty) return false;
    if (cleanCurrent == cleanApi) return false;

    final baseCurrent = cleanCurrent.split('+').first.trim();
    final baseApi = cleanApi.split('+').first.trim();

    if (baseCurrent != baseApi) {
      return true;
    }

    // If base versions are identical, compare build numbers if both provide one
    if (cleanCurrent.contains('+') && cleanApi.contains('+')) {
      return cleanCurrent != cleanApi;
    }

    return false;
  }

  /// Selects the appropriate [AppVersion] depending on whether running on iOS or Android.
  static AppVersion getPlatformAppVersion(DeliveryAppData data) {
    if (Platform.isIOS) {
      return data.deliveryIosAppVersion;
    } else {
      // Default to Android for Android and other platforms
      return data.deliveryAndroidAppVersion;
    }
  }

  /// Checks the current app version against the API version and displays
  /// the non-dismissible update alert dialog if they are different.
  static Future<void> checkAndShow(BuildContext context, DeliveryAppData data) async {
    if (_isDialogOpen) return;

    try {
      final targetVersion = getPlatformAppVersion(data);
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      logger.i(
        "AppUpdateCheck -> Current: $currentVersion, API: ${targetVersion.version}, Force: ${targetVersion.forceUpdate}",
      );

      if (isVersionDifferent(currentVersion, targetVersion.version)) {
        if (!context.mounted) return;
        _isDialogOpen = true;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AppUpdateDialogWidget(
            appVersion: targetVersion,
            currentVersion: currentVersion,
            onCancel: () {
              _isDialogOpen = false;
              Navigator.of(dialogContext, rootNavigator: true).pop();
            },
          ),
        );

        _isDialogOpen = false;
      }
    } catch (e) {
      logger.e("AppUpdateDialogWidget: checkAndShow failed: $e");
    }
  }

  /// Opens the store URL using [url_launcher].
  static Future<void> _launchStoreUrl(String url) async {
    if (url.trim().isEmpty) return;
    final uri = Uri.tryParse(url.trim());
    if (uri != null) {
      try {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        logger.e("AppUpdateDialogWidget: Error opening update URL: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent closing the dialog through back button/gesture at all costs
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Dialog cannot be dismissed via back gesture/hardware back button
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Update Icon Badge ─────────────────────────────────────
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF2E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: AppColor.darkOrange,
                  size: 36,
                ),
              ),

              const SizedBox(height: 18),

              // ── Title ────────────────────────────────────────────────
              Text(
                'Update Available',
                style: AppFont.style(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0D121F),
                ),
              ),

              if (appVersion.version.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.border),
                  ),
                  child: Text(
                    'Version ${appVersion.version}',
                    style: AppFont.style(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkOrange,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // ── API Update Message ────────────────────────────────────
              Text(
                appVersion.updateMessage.isNotEmpty
                    ? appVersion.updateMessage
                    : 'A new version of the application is available. Please update to continue using the latest features.',
                textAlign: TextAlign.center,
                style: AppFont.style(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5C616E),
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 24),

              // ── Action Buttons ────────────────────────────────────────
              if (!appVersion.forceUpdate) ...[
                // Non-force update: Show both Cancel and Update buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: () {
                            if (onCancel != null) {
                              onCancel!();
                            } else {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF6F6F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppFont.style(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
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
                          onPressed: () => _launchStoreUrl(appVersion.storeLink),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.darkOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Update',
                            style: AppFont.style(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Force update: Do not show Cancel button, show only Update button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _launchStoreUrl(appVersion.storeLink),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.darkOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Update Now',
                      style: AppFont.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
