import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WalletCardWidget extends StatelessWidget {
  final num? totalEarning;
  final num? todaysEarning;
  final num? avgRating;
  final int? totalDeliveries;

  const WalletCardWidget({
    super.key,
    this.totalEarning,
    this.todaysEarning,
    this.avgRating,
    this.totalDeliveries,
  });

  @override
  Widget build(BuildContext context) {
    final totalDisplay = totalEarning != null
        ? '₹${totalEarning!.toStringAsFixed(0)}'
        : '₹0';
    final todaysDisplay = todaysEarning != null
        ? '₹${todaysEarning!.toStringAsFixed(0)}'
        : '₹0';
    final deliveriesDisplay =
        totalDeliveries != null ? '$totalDeliveries' : '0';
    final ratingDisplay =
        avgRating != null ? avgRating!.toStringAsFixed(1) : '0.0';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.darkOrange.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColor.border.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColor.orangeTint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColor.darkOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'drawer_total_earnings'.tr(),
                            style: const TextStyle(
                              color: AppColor.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          totalEarning != null
                              ? Text(
                                  totalDisplay,
                                  style: const TextStyle(
                                    color: AppColor.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                )
                              : Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.white,
                                  child: Container(
                                    width: 70,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.darkOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFFFDFC2)),
          const SizedBox(height: 12),

          // Daily Metrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                "Today's Pay",
                todaysDisplay,
                Icons.payments_rounded,
                todaysEarning == null,
              ),
              Container(height: 30, width: 1, color: Colors.grey.shade200),
              _buildMetricItem(
                'Deliveries',
                deliveriesDisplay,
                Icons.local_shipping_rounded,
                totalDeliveries == null,
              ),
              Container(height: 30, width: 1, color: Colors.grey.shade200),
              _buildMetricItem(
                'Rating',
                '$ratingDisplay ★',
                Icons.star_rounded,
                avgRating == null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    bool isLoading,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColor.darkOrange),
            const SizedBox(width: 4),
            isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.white,
                    child: Container(
                      width: 45,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColor.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
