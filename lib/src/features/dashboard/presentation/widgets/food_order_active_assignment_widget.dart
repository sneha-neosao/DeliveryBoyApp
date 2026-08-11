import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_assignment_bloc/order_assignment_bloc.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FoodOrderActiveAssignmentWidget extends StatelessWidget {
  final int orderCount;
  final String assignmentStatus;
  final String orderStatus;
  final String uuid;

  const FoodOrderActiveAssignmentWidget({
    super.key,
    required this.orderCount,
    required this.assignmentStatus,
    required this.orderStatus,
    required this.uuid,
  });

  @override
  Widget build(BuildContext context) {
    final aStatus = assignmentStatus.toUpperCase();
    final oStatus = orderStatus.toUpperCase();

    // Logic as requested:
    // in food one if order status is PREPAIRING show the buttons RELEASE and ACCEPT
    // and other all statuses do not show any button
    // (Checking both assignmentStatus and orderStatus to be safe, as they might be used interchangeably)
    final bool showFoodActions = aStatus == 'PREPAIRING' || aStatus == 'PREPARING' || 
                                 oStatus == 'PREPAIRING' || oStatus == 'PREPARING';

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
                  if (showFoodActions) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: () => _showReleaseDialog(context, uuid),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColor.bright_red,
                            side: const BorderSide(
                              color: AppColor.bright_red,
                              width: 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'RELEASE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            context.read<OrderAssignmentBloc>().add(
                                  OrderAssignmentGetEvent(
                                    uuid,
                                    'DEL_ACCEPTED',
                                    null,
                                  ),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.darkOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ACCEPT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 14),
                            ],
                          ),
                        ),
                      ],
                    )
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

  void _showReleaseDialog(BuildContext context, String uuid) {
    final TextEditingController reasonCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFEEEE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cancel_outlined,
                              color: AppColor.bright_red, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Release Order',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: reasonCtrl,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Enter release reason',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFFFF9F5),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColor.darkOrange, width: 1.5),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter reason';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            final reason = reasonCtrl.text.trim();
                            Navigator.of(dialogCtx).pop();
                            context.read<OrderAssignmentBloc>().add(
                                  OrderAssignmentGetEvent(
                                    uuid,
                                    'REJECTED',
                                    reason,
                                  ),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.darkOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SUBMIT',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) => reasonCtrl.dispose());
  }
}
