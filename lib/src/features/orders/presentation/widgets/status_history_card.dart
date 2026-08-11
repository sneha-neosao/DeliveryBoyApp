import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_details_response.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StatusHistoryCard extends StatelessWidget {
  final List<StatusLog> statusLogs;

  const StatusHistoryCard({
    super.key,
    required this.statusLogs,
  });

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PLACED':
        return 'PLACED';
      case 'PENDING':
        return 'PENDING';
      case 'ACCEPTED':
        return 'ACCEPTED';
      case 'DEL_ACCEPTED':
        return 'DELIVERY ACCEPTED';
      case 'PREPARING':
        return 'PREPARING';
      case 'READY_FOR_PICKUP':
        return 'READY FOR PICK UP';
      case 'PICKED_UP':
        return 'PICKED UP';
      case 'ON_THE_WAY':
        return 'ON THE WAY';
      case 'DELIVERED':
        return 'DELIVERED';
      case 'CANCELLED':
        return 'CANCELLED';
      case 'REJECTED':
        return 'REJECTED';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

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
                const Icon(Icons.history_rounded, color: AppColor.darkOrange, size: 20),
                8.wS,
                Text(
                  'status_history'.tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.charcoal),
                ),
              ],
            ),
            16.hS,
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            16.hS,
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: statusLogs.length,
              itemBuilder: (context, index) {
                final log = statusLogs[index];
                final isLast = index == statusLogs.length - 1;
                String formattedTime = '';
                try {
                  final dateTime = DateTime.parse(log.createdAt);
                  formattedTime = DateFormat('dd MMM yyyy, hh:mm a').format(dateTime.toLocal());
                } catch (_) {
                  formattedTime = log.createdAt;
                }

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isLast ? AppColor.darkOrange : const Color(0xFFFFD9BD),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isLast ? Colors.white : const Color(0xFFFFEAD9),
                                width: 2,
                              ),
                              boxShadow: isLast
                                  ? [
                                      BoxShadow(
                                        color: AppColor.darkOrange.withValues(alpha: 0.4),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: const Color(0xFFFFD9BD),
                              ),
                            ),
                        ],
                      ),
                      16.wS,
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatStatus(log.toStatus),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isLast ? AppColor.darkOrange : AppColor.charcoal,
                                    ),
                                  ),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                  ),
                                ],
                              ),
                              if (log.note.isNotEmpty) ...[
                                4.hS,
                                Text(
                                  log.note,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                              4.hS,
                              Text(
                                '${'changed_by'.tr()}: ${log.changedBy}',
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
