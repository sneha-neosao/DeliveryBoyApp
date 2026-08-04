import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BottomNavItem {
  final String path;
  final String labelKey;
  final IconData icon;
  final IconData selectedIcon;

  const BottomNavItem({
    required this.path,
    required this.labelKey,
    required this.icon,
    required this.selectedIcon,
  });
}

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int index) onTap;

  static const List<BottomNavItem> navItems = [
    BottomNavItem(
      path: '/dashboard_screen',
      labelKey: 'dashboard',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
    ),
    BottomNavItem(
      path: '/orders_screen',
      labelKey: 'drawer_orders',
      icon: Icons.shopping_bag_outlined,
      selectedIcon: Icons.shopping_bag_rounded,
    ),
    BottomNavItem(
      path: '/profile_screen',
      labelKey: 'drawer_profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  Alignment _getItemAlignment(int index) {
    if (index == 0) return Alignment.centerLeft;
    if (index == navItems.length - 1) return Alignment.centerRight;
    return Alignment.center;
  }

  EdgeInsets _getItemMargin(int index) {
    if (index == 0) return const EdgeInsets.only(left: 12);
    if (index == navItems.length - 1) return const EdgeInsets.only(right: 12);
    return EdgeInsets.zero;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.whiteDark,
                AppColor.white,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.darkOrange.withValues(alpha: 0.18),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: AppColor.border.withValues(alpha: 0.6),
              width: 1.2,
            ),
          ),
          child: Row(
            children: List.generate(navItems.length, (index) {
              final isSelected = index == selectedIndex;
              final item = navItems[index];

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Align(
                    alignment: _getItemAlignment(index),
                    child: Padding(
                      padding: _getItemMargin(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        clipBehavior: Clip.antiAlias,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 12 : 8,
                          vertical: isSelected ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColor.orangeTint
                              : AppColor.orangeTint.withValues(alpha: 0.0),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.darkOrange
                                  .withValues(alpha: isSelected ? 0.15 : 0.0),
                              blurRadius: isSelected ? 10 : 0,
                              offset: isSelected ? const Offset(0, 3) : Offset.zero,
                            ),
                          ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated Glowing Icon Container
                              AnimatedScale(
                                scale: isSelected ? 1.08 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutBack,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColor.darkOrange.withValues(alpha: isSelected ? 1.0 : 0.0),
                                        AppColor.primaryLight2.withValues(alpha: isSelected ? 1.0 : 0.0),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.darkOrange
                                            .withValues(alpha: isSelected ? 0.35 : 0.0),
                                        blurRadius: isSelected ? 6 : 0,
                                        offset: isSelected ? const Offset(0, 2) : Offset.zero,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isSelected ? item.selectedIcon : item.icon,
                                    size: 20,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColor.slateGrey,
                                  ),
                                ),
                              ),

                              // Animated Text Label when selected
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                child: isSelected
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 2),
                                          Text(
                                            item.labelKey.tr(),
                                            style: const TextStyle(
                                              color: AppColor.darkOrange,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
