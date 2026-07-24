import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InfoCardWidget extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onOnlineToggle;
  final String? userName;
  final String? userPhone;

  const InfoCardWidget({
    super.key,
    required this.isOnline,
    required this.onOnlineToggle,
    this.userName,
    this.userPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 60,
            left: 20,
            right: 20,
            bottom: 32,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.darkOrange,
                AppColor.primaryLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              // Top Row: App Title & Online Status Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'drawer_title'.tr(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'dashboard'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Online / Offline Status Toggle Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isOnline
                              ? 'home_status_online'.tr()
                              : 'home_status_offline'.tr(),
                          style: TextStyle(
                            color: isOnline
                                ? const Color(0xFFFA6624)
                                : const Color(0xFF7A869A),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 30,
                          child: Switch(
                            value: isOnline,
                            onChanged: onOnlineToggle,
                            activeThumbColor: AppColor.primary,
                            activeTrackColor:
                                AppColor.primaryDark.withValues(alpha: 0.3),
                            inactiveThumbColor: AppColor.gray,
                            inactiveTrackColor: AppColor.white,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Profile Picture & Name Card
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.orangeTint2,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_pin_rounded,
                      size: 40,
                      color: AppColor.darkOrange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (userName != null && userName!.isNotEmpty) ? userName! : 'Neosao Partner',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_android_rounded,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (userPhone != null && userPhone!.isNotEmpty) ? userPhone! : '+91 8482940592',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // IconButton(
                  //   onPressed: () {
                  //     context.go(AppRoute.profile.path);
                  //   },
                  //   icon: const Icon(
                  //     Icons.edit_note_rounded,
                  //     color: Colors.white,
                  //     size: 26,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
