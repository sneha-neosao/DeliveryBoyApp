import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_details_response.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OrderDetailsWidget extends StatelessWidget {
  final OrderDetails orderDetails;

  const OrderDetailsWidget({
    super.key,
    required this.orderDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Metrics row: items, amount, payment
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9F3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFEAD9), width: 1),
          ),
          child: Row(
            children: [
              _buildMetricItem(Icons.shopping_bag_outlined, '${orderDetails.totalItems}', 'items'.tr()),
              _buildDivider(),
              _buildMetricItem(Icons.account_balance_wallet_outlined, '₹${orderDetails.grandTotal}', 'amount'.tr()),
              _buildDivider(),
              _buildMetricItem(
                Icons.local_atm_rounded,
                orderDetails.paymentMode.isNotEmpty ? orderDetails.paymentMode : 'cod'.tr(),
                'payment'.tr(),
              ),
            ],
          ),
        ),
        16.hS,
        // Time / slot info card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFF2B3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.access_time_filled_rounded, color: AppColor.darkOrange, size: 18),
                  10.wS,
                  Expanded(
                    child: Text(
                      '${'delivery_instruction'.tr()} (${orderDetails.slotStartTime} - ${orderDetails.slotEndTime}).',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              if (orderDetails.note.isNotEmpty) ...[
                10.hS,
                const Divider(color: Color(0xFFFFF2B3), height: 1),
                10.hS,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.assignment_rounded, color: AppColor.darkOrange, size: 18),
                    10.wS,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'customer_note'.tr(),
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          4.hS,
                          Text(
                            orderDetails.note,
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColor.darkOrange, size: 24),
          6.hS,
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          2.hS,
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 36,
      width: 1,
      color: const Color(0xFFFFEAD9),
    );
  }
}
