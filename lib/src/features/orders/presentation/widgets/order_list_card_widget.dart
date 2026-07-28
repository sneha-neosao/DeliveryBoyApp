import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderListCardWidget extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderListCardWidget({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String displayId = order.uuId.isNotEmpty
        ? '#${order.uuId.substring(0, order.uuId.length > 8 ? 8 : order.uuId.length)}'
        : '#ORD-${order.id}';
    final String statusText = order.orderStatus.isNotEmpty
        ? order.orderStatus
        : (order.isAssigned ? 'assigned'.tr() : 'pending'.tr());
    final bool isAssigned = statusText.toLowerCase() == 'assigned' || order.isAssigned;
    final String customer = order.customerName.isNotEmpty ? order.customerName : order.deliveryName;
    final String timeStr = order.slotStartTime.isNotEmpty
        ? '${order.slotStartTime} - ${order.slotEndTime}'
        : order.deliveryDate;

    return GestureDetector(
      onTap: onTap ?? () => context.push(AppRoute.orderDetails.path, extra: order),
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
            // Top Row: Order ID & Status Badge
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
                    color: isAssigned ? const Color(0xFFFFF2E6) : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: isAssigned ? const Color(0xFFFA6624) : const Color(0xFF2E7D32),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            10.hS,
            const Divider(height: 1, color: Color(0xFFF5F5F5)),
            10.hS,

            // Store / Items Row
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF2E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.store_rounded, color: Color(0xFFFA6624), size: 20),
                ),
                12.wS,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.isNotEmpty ? customer : 'delivery_order'.tr(),
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
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFFA6624), size: 24),
              ],
            ),
            10.hS,

            // Address & Slot Row
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Color(0xFFFA6624), size: 16),
                6.wS,
                Expanded(
                  child: Text(
                    order.deliveryAddress.isNotEmpty
                        ? order.deliveryAddress
                        : 'delivery_address_not_specified'.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (timeStr.isNotEmpty) ...[
                  8.wS,
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
