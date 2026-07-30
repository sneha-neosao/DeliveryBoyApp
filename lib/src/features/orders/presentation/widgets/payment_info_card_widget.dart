import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_details_response.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PaymentInfoCardWidget extends StatelessWidget {
  final OrderDetails orderDetails;

  const PaymentInfoCardWidget({
    super.key,
    required this.orderDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: AppColor.darkOrange, size: 20),
                8.wS,
                Text(
                  'payment'.tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.charcoal),
                ),
              ],
            ),
            12.hS,
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            12.hS,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('subtotal'.tr(), style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                Text('₹${orderDetails.totalAmount}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
            8.hS,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('platform_charges_label'.tr(), style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                Text('₹${orderDetails.platformCharges}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
            12.hS,
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            12.hS,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('grand_total_label'.tr(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15, color: AppColor.charcoal)),
                Text('₹${orderDetails.grandTotal}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: AppColor.darkOrange)),
              ],
            ),
            12.hS,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2E6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColor.darkOrange, size: 16),
                      6.wS,
                      Text('payment_status_label'.tr(),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold, color: AppColor.darkOrange)),
                    ],
                  ),
                  Text(
                    orderDetails.paymentStatus,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold, color: AppColor.darkOrange),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
