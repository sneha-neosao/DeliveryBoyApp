import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DeliveryAddressCardWidget extends StatelessWidget {
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;

  const DeliveryAddressCardWidget({
    super.key,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              4.hS,
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF2E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.store_rounded, color: AppColor.darkOrange, size: 14),
              ),
              CustomPaint(
                size: const Size(2, 60),
                painter: _DottedLinePainter(),
              ),
              const Icon(Icons.location_on_rounded, color: AppColor.darkOrange, size: 24),
            ],
          ),
          14.wS,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName.isNotEmpty ? customerName : 'customer'.tr(),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          2.hS,
                          Text(
                            customerPhone.isNotEmpty ? customerPhone : 'no_contact_info'.tr(),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPhoneCircle(),
                  ],
                ),
                38.hS,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'delivery_address'.tr(),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          2.hS,
                          Text(
                            deliveryAddress,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneCircle() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: const Icon(Icons.phone_rounded, color: AppColor.darkOrange, size: 16),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.darkOrange.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double dashHeight = 4;
    const double dashSpace = 4;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
