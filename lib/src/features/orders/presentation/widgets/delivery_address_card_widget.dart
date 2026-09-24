import 'dart:math' as math;
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryAddressCardWidget extends StatelessWidget {
  final String? pickupName;
  final String? pickupAddress;
  final String? pickupPhone;
  final bool isVendor;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final bool showNavigationIcon;
  final bool showPickupCallButton;
  final VoidCallback? onNavigationTap;

  const DeliveryAddressCardWidget({
    super.key,
    this.pickupName,
    this.pickupAddress,
    this.pickupPhone,
    this.isVendor = false,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    this.showNavigationIcon = false,
    this.showPickupCallButton = false,
    this.onNavigationTap,
  });

  Future<void> _callPhone(String phone) async {
    final cleanPhone = phone.trim();
    if (cleanPhone.isEmpty) return;
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch phone: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String effectivePickupAddress = pickupAddress?.trim().isNotEmpty == true
        ? pickupAddress!.trim()
        : (isVendor ? 'restaurant_address'.tr() : 'store_address'.tr());

    final String? effectiveSubtitleName = (pickupName?.trim().isNotEmpty == true &&
            pickupName!.trim().toLowerCase() != effectivePickupAddress.toLowerCase())
        ? pickupName!.trim()
        : null;

    final String effectiveCustomerName = customerName.trim().isNotEmpty
        ? customerName.trim()
        : 'customer'.tr();

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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left route indicator
            Column(
              children: [
                const SizedBox(height: 2),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF2E6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isVendor ? Icons.restaurant_rounded : Icons.store_rounded,
                    color: AppColor.darkOrange,
                    size: 14,
                  ),
                ),
                Expanded(
                  child: CustomPaint(
                    size: const Size(2, double.infinity),
                    painter: _DottedLinePainter(),
                  ),
                ),
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColor.darkOrange,
                  size: 24,
                ),
                const SizedBox(height: 2),
              ],
            ),
            const SizedBox(width: 14),
            // Right info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Section: Store / Restaurant ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              effectivePickupAddress,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (effectiveSubtitleName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                effectiveSubtitleName,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  height: 1.3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (showPickupCallButton && pickupPhone != null && pickupPhone!.trim().isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildCircleButton(
                          icon: Icons.phone_rounded,
                          onTap: () => _callPhone(pickupPhone!),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  // ── Bottom Section: Customer & Delivery Address ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Customer name (just above delivery address)
                            Text(
                              effectiveCustomerName,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (customerPhone.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                customerPhone.trim(),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            // Delivery address
                            Text(
                              deliveryAddress.trim().isNotEmpty
                                  ? deliveryAddress.trim()
                                  : 'address_not_available'.tr(),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildCustomerActionButtons(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (customerPhone.trim().isNotEmpty)
          _buildCircleButton(
            icon: Icons.phone_rounded,
            onTap: () => _callPhone(customerPhone),
          ),
        if (showNavigationIcon) ...[
          const SizedBox(width: 8),
          _buildCircleButton(
            icon: Icons.navigation,
            isNavigation: true,
            onTap: onNavigationTap,
          ),
        ],
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    bool isNavigation = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColor.darkOrange,
            width: 1.5,
          ),
        ),
        child: isNavigation
            ? Transform.rotate(
                angle: math.pi / 4,
                child: Icon(
                  icon,
                  color: AppColor.darkOrange,
                  size: 18,
                ),
              )
            : Icon(
                icon,
                color: AppColor.darkOrange,
                size: 18,
              ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0) return;
    final paint = Paint()
      ..color = AppColor.darkOrange.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double dashHeight = 4;
    const double dashSpace = 4;
    double startY = 4;
    while (startY < size.height - 4) {
      final double endY = math.min(startY + dashHeight, size.height - 4);
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, endY),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
