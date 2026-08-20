import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_start_assignment_bloc/order_start_assignment_bloc.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VegetableOrderActiveAssignmentWidget extends StatefulWidget {
  final int orderCount;
  final String status;
  final String uuid;
  final String paymentMode;
  final String autoAssignMode;

  const VegetableOrderActiveAssignmentWidget({
    super.key,
    required this.orderCount,
    required this.status,
    required this.uuid,
    this.paymentMode = '',
    this.autoAssignMode = '',
  });

  @override
  State<VegetableOrderActiveAssignmentWidget> createState() => _VegetableOrderActiveAssignmentWidgetState();
}

class _VegetableOrderActiveAssignmentWidgetState extends State<VegetableOrderActiveAssignmentWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _checkAnimation();
  }

  @override
  void didUpdateWidget(covariant VegetableOrderActiveAssignmentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAnimation();
  }

  void _checkAnimation() {
    final assignmentStatus = widget.status.toUpperCase();
    bool shouldAnimate = assignmentStatus == 'PREPAIRING' || assignmentStatus == 'PREPARING';
    
    if (shouldAnimate) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assignmentStatus = widget.status.toUpperCase();
    final normalizedMode = widget.autoAssignMode.trim().toLowerCase().replaceAll('_', '-');
    final bool isAutoAssign = normalizedMode == 'auto-assign';

    bool showStart = assignmentStatus == 'PREPAIRING' || assignmentStatus == 'PREPARING';
    bool showInactivePickedUp = assignmentStatus == 'DEL_ACCEPTED';
    bool showActivePickedUp = assignmentStatus == 'READY_FOR_PICKUP';

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
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
                      'Active Assignment (${widget.orderCount})',
                      style: const TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (showStart || showInactivePickedUp || showActivePickedUp) ...[
                      const SizedBox(height: 6),
                      if (showStart)
                        if (isAutoAssign)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton(
                                onPressed: () => _showReleaseDialog(context, widget.uuid),
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
                                  context.read<OrderStartAssignmentBloc>().add(
                                        OrderStartAssignmentGetEvent(
                                          widget.uuid,
                                          'DEL_ACCEPTED',
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
                        else
                          InkWell(
                            onTap: () {
                              context.read<OrderStartAssignmentBloc>().add(
                                    OrderStartAssignmentGetEvent(
                                      widget.uuid,
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
                                    widget.uuid,
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
            padding: const EdgeInsets.all(20),
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
                          Navigator.of(dialogCtx).pop();
                          context.read<OrderStartAssignmentBloc>().add(
                                OrderStartAssignmentGetEvent(
                                  uuid,
                                  'REJECTED',
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
        );
      },
    );
  }
}
