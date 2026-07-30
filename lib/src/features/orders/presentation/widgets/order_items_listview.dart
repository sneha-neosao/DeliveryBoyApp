import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_details_response.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OrderItemsListview extends StatelessWidget {
  final List<Item> items;

  const OrderItemsListview({
    super.key,
    required this.items,
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
                const Icon(Icons.shopping_basket_rounded, color: AppColor.darkOrange, size: 20),
                8.wS,
                Text(
                  'order_items'.tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.charcoal),
                ),
              ],
            ),
            12.hS,
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            8.hS,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFFCEFE6)),
              itemBuilder: (context, index) {
                final item = items[index];
                return Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2E6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: item.images.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.restaurant, color: AppColor.darkOrange, size: 24),
                              ),
                            )
                          : const Icon(Icons.restaurant, color: AppColor.darkOrange, size: 24),
                    ),
                    12.wS,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14, color: AppColor.charcoal),
                          ),
                          4.hS,
                          Text(
                            '${item.variantName} • ${item.uomName}',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${item.price} x ${item.quantity}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        4.hS,
                        Text(
                          '₹${item.totalPrice}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14, color: AppColor.darkOrange),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
