import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_start_assignment_bloc/order_start_assignment_bloc.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VegetableOrderActiveAssignmentWidget extends StatelessWidget {
  final int orderCount;
  final String status;
  final String uuid;

  const VegetableOrderActiveAssignmentWidget({
    super.key,
    required this.orderCount,
    required this.status,
    required this.uuid,
  });

  @override
  Widget build(BuildContext context) {
    final assignmentStatus = status.toUpperCase();

    // Logic as requested:
    // if status is PREPAIRING then show START button
    // if status is DEL_ACCEPTED then show the PICKED UP inactive button
    // if status is READY_FOR_PICKUP then show PICKED_UP active button
    // for other all status no button will be shown on the card

    bool showStart = assignmentStatus == 'PREPAIRING' || assignmentStatus == 'PREPARING';
    bool showInactivePickedUp = assignmentStatus == 'DEL_ACCEPTED';
    bool showActivePickedUp = assignmentStatus == 'READY_FOR_PICKUP';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFF2E6),
              Color(0xFFFFE8D6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.shopping_bag_rounded,
              color: AppColor.darkOrange,
              size: 32,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Assignment ($orderCount)',
                    style: const TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showStart || showInactivePickedUp || showActivePickedUp) ...[
                    const SizedBox(height: 6),
                    if (showStart)
                      InkWell(
                        onTap: () {
                          context.read<OrderStartAssignmentBloc>().add(
                                OrderStartAssignmentGetEvent(
                                  uuid,
                                  'DEL_ACCEPTED',
                                ),
                              );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.darkOrange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'START',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (showInactivePickedUp)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_bag_rounded,
                              color: Colors.grey.shade500,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PICKED UP',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (showActivePickedUp)
                      InkWell(
                        onTap: () {
                          context.read<OrderStartAssignmentBloc>().add(
                                OrderStartAssignmentGetEvent(
                                  uuid,
                                  'PICKED_UP',
                                ),
                              );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.darkOrange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_bag_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'PICKED UP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                context.go(AppRoute.orders.path);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.darkOrange,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: AppColor.darkOrange,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
