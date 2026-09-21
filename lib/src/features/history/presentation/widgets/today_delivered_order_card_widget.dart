import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/today_delivered_history_response.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TodayDeliveredOrderCardWidget extends StatelessWidget {
  final TodayDeliveredOrder order;
  final VoidCallback? onTap;

  const TodayDeliveredOrderCardWidget({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String displayId = 'ORD_${order.id}';

    final String customer = order.customerName.isNotEmpty
        ? order.customerName
        : (order.deliveryName.isNotEmpty ? order.deliveryName : 'Customer');

    String formattedTime = '';
    if (order.deliveryDate.isNotEmpty) {
      try {
        final dt = DateTime.parse(order.deliveryDate).toLocal();
        formattedTime = DateFormat('hh:mm a').format(dt);
      } catch (_) {
        formattedTime = order.deliveryDate;
      }
    }

    return GestureDetector(
      onTap: onTap ??
          () {
            final deliveryType = SessionManager.deliveryTypeNotifier.value?.toLowerCase();
            final isFood = deliveryType == 'food';
            if (isFood) {
              context.push(
                AppRoute.orderDetails.path,
                extra: order.toOrder(),
              );
            } else {
              context.push(
                AppRoute.bulkOrderDetails.path,
                extra: order.toOrder(),
              );
            }
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Order ID & Delivered Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayId,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D121F),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF16A34A),
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'DELIVERED',
                        style: TextStyle(
                          color: Color(0xFF16A34A),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            10.hS,
            const Divider(height: 1, color: Color(0xFFF5F5F5)),
            10.hS,

            // Customer & Items Row
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF2E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: AppColor.darkOrange,
                    size: 20,
                  ),
                ),
                12.wS,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      2.hS,
                      Text(
                        '${order.totalItems} ${'items'.tr()} • ₹${order.grandTotal}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColor.darkOrange,
                  size: 24,
                ),
              ],
            ),
            10.hS,

            // Address Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColor.darkOrange,
                    size: 16,
                  ),
                ),
                6.wS,
                Expanded(
                  child: Text(
                    order.deliveryAddress.isNotEmpty
                        ? order.deliveryAddress
                        : 'delivery_address_not_specified'.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            12.hS,
            const Divider(height: 1, color: Color(0xFFF5F5F5)),
            10.hS,

            // Bottom Row: Payment & Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.paymentMode.isNotEmpty ? order.paymentMode : 'COD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    if (order.paymentStatus.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: order.paymentStatus.toUpperCase() == 'PAID'
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF9C3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.paymentStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: order.paymentStatus.toUpperCase() == 'PAID'
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFCA8A04),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (formattedTime.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
