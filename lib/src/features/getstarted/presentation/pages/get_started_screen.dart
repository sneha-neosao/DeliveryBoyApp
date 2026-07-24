import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_route_path.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/get_started_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Content Overlay
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  90.hS,
                  // Title Texts
                  Text(
                    'get_started_title_part1'.tr(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColor.charcoal, // Dark Charcoal
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'get_started_title_part2'.tr(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColor.charcoal, // Dark Charcoal
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'get_started_title_part3'.tr(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColor.darkOrange, // Orange
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'get_started_title_part4'.tr(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColor.darkOrange, // Orange
                      height: 1.1,
                    ),
                  ),
                  12.hS,
                  // Horizontal Accent Line
                  Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColor.darkOrange, // Orange
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  16.hS,
                  // Subtitle
                  Text(
                    'get_started_subtitle'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColor.slateGrey,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  24.hS,
                  // Info Card (Made smaller and narrower to minimize spacing)
                  Container(
                    width: 280,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColor.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoColumn(
                          icon: Icons.electric_bolt_rounded,
                          title: 'get_started_fast_delivery'.tr(),
                          subtitle: 'get_started_fast_delivery_sub'.tr(),
                        ),
                        _buildDivider(),
                        _buildInfoColumn(
                          icon: Icons.shopping_bag_outlined,
                          title: 'get_started_wide_range'.tr(),
                          subtitle: 'get_started_wide_range_sub'.tr(),
                        ),
                        _buildDivider(),
                        _buildInfoColumn(
                          icon: Icons.gpp_good_outlined,
                          title: 'get_started_safe_secure'.tr(),
                          subtitle: 'get_started_safe_secure_sub'.tr(),
                        ),
                      ],
                    ),
                  ),
                  100.hS,
                ],
              ),
            ),
          ),
          // Get Started Button
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.darkOrange,
                  foregroundColor: AppColor.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                  shadowColor: AppColor.darkOrange.withValues(alpha: 0.4),
                ),
                onPressed: () {
                  context.go(AppRoute.login.path);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'get_started_button'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    8.wS,
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColor.darkOrange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 14,
            ),
          ),
          6.hS,
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColor.charcoal, // Dark Charcoal
            ),
          ),
          2.hS,
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              color: AppColor.slateGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 28,
      width: 1,
      color: AppColor.grey.withValues(alpha: 0.25),
    );
  }
}
