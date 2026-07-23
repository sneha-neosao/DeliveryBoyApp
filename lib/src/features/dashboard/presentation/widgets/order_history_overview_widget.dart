import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderHistoryOverviewWidget extends StatelessWidget {
  const OrderHistoryOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildShortcutCard(
            title: 'drawer_delivered'.tr(),
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF188510),
            bgColor: const Color(0xFFE8F5E9),
            onTap: () => context.go(AppRoute.orders.path),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildShortcutCard(
            title: 'drawer_cancelled'.tr(),
            icon: Icons.cancel_rounded,
            color: Colors.orange.shade800,
            bgColor: Colors.orange.shade50,
            onTap: () => context.go(AppRoute.orders.path),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildShortcutCard(
            title: 'drawer_rejected'.tr(),
            icon: Icons.remove_circle_rounded,
            color: const Color(0xFFE62222),
            bgColor: const Color(0xFFFFEBEE),
            onTap: () => context.go(AppRoute.orders.path),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
