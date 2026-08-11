import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_status_update_bloc/order_status_update_bloc.dart';
import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_list_bloc/order_list_bloc.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/food_order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // Map raw API status → human-readable label
    String _statusLabel(String raw) {
      switch (raw.toUpperCase()) {
        case 'DEL_ACCEPTED':      return 'DELIVERY ACCEPTED';
        case 'ON_THE_WAY':        return 'ON THE WAY';
        case 'PICKED_UP':         return 'PICKED UP';
        case 'READY_FOR_PICKUP':  return 'READY FOR PICK UP';
        case 'PREPARING':         return 'PREPARING';
        case 'DELIVERED':         return 'DELIVERED';
        case 'ACCEPTED':          return 'ACCEPTED';
        case 'PLACED':            return 'PLACED';
        case 'PENDING':           return 'PENDING';
        case 'ASSIGNED':          return 'ASSIGNED';
        default:                  return raw.isNotEmpty ? raw : (order.isAssigned ? 'ASSIGNED' : 'PENDING');
      }
    }

    // Badge background + text colour per status
    Color _badgeBg(String raw) {
      switch (raw.toUpperCase()) {
        case 'DEL_ACCEPTED':      return const Color(0xFFE0F2FE); // light blue
        case 'ON_THE_WAY':        return const Color(0xFFEDE9FE); // light purple
        case 'PICKED_UP':         return const Color(0xFFEDE9FE); // light purple
        case 'READY_FOR_PICKUP':  return const Color(0xFFFEF9C3); // light yellow
        case 'PREPARING':         return const Color(0xFFFEF9C3); // light yellow
        case 'DELIVERED':         return const Color(0xFFDCFCE7); // light green
        case 'ACCEPTED':          return const Color(0xFFDCFCE7); // light green
        default:                  return const Color(0xFFFFF2E6); // default orange tint
      }
    }

    Color _badgeFg(String raw) {
      switch (raw.toUpperCase()) {
        case 'DEL_ACCEPTED':      return const Color(0xFF0284C7); // blue
        case 'ON_THE_WAY':        return const Color(0xFF7C3AED); // purple
        case 'PICKED_UP':         return const Color(0xFF7C3AED); // purple
        case 'READY_FOR_PICKUP':  return const Color(0xFFCA8A04); // amber
        case 'PREPARING':         return const Color(0xFFCA8A04); // amber
        case 'DELIVERED':         return const Color(0xFF16A34A); // green
        case 'ACCEPTED':          return const Color(0xFF16A34A); // green
        default:                  return const Color(0xFFFA6624); // orange
      }
    }

    final String rawStatus = order.orderStatus;
    final String statusLabel = _statusLabel(rawStatus);
    final Color badgeBg     = _badgeBg(rawStatus);
    final Color badgeFg     = _badgeFg(rawStatus);
    final String customer   = order.customerName.isNotEmpty ? order.customerName : order.deliveryName;
    final String timeStr    = order.slotStartTime.isNotEmpty
        ? '${order.slotStartTime} - ${order.slotEndTime}'
        : order.deliveryDate;

    return GestureDetector(
      onTap: onTap ??
          () async {
            final result = await context.push<bool>(
              AppRoute.orderDetails.path,
              extra: order,
            );
            // If the detail screen popped with true it means a status update
            // succeeded — refresh the order list from page 1.
            if (result == true && context.mounted) {
              context
                  .read<OrderListBloc>()
                  .add(const GetOrderListEvent(page: 1));
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
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: badgeFg,
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
            if (_shouldShowButton(rawStatus)) ...[
              16.hS,
              _buildActionButton(context, rawStatus),
            ],
          ],
        ),
      ),
    );
  }

  bool _shouldShowButton(String status) {
    switch (status.toUpperCase()) {
      case 'DEL_ACCEPTED':
      case 'READY_FOR_PICKUP':
      case 'PICKED_UP':
      case 'ON_THE_WAY':
        return true;
      default:
        return false;
    }
  }

  Widget _buildActionButton(BuildContext context, String status) {
    String buttonText = '';
    IconData? icon;
    bool isActive = true;
    String nextStatus = '';

    switch (status.toUpperCase()) {
      case 'DEL_ACCEPTED':
        buttonText = 'PICKED UP';
        icon = Icons.shopping_bag_rounded;
        isActive = false;
        break;
      case 'READY_FOR_PICKUP':
        buttonText = 'PICKED UP';
        icon = Icons.shopping_bag_rounded;
        nextStatus = 'PICKED_UP';
        break;
      case 'PICKED_UP':
        buttonText = 'ON THE WAY';
        icon = Icons.delivery_dining_rounded;
        nextStatus = 'ON_THE_WAY';
        break;
      case 'ON_THE_WAY':
        buttonText = 'DELIVERED';
        icon = Icons.check_circle_rounded;
        nextStatus = 'DELIVERED';
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: isActive
            ? () {
                context.read<OrderStatusUpdateBloc>().add(
                      OrderStatusUpdateGetEvent(
                        order.uuId,
                        nextStatus,
                        null,
                      ),
                    );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? AppColor.darkOrange : Colors.grey.shade300,
          foregroundColor: isActive ? Colors.white : Colors.grey.shade500,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
          elevation: isActive ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              8.wS,
            ],
            Text(
              buttonText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
