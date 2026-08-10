import 'dart:math' as math;

import 'package:delivery_boy_app/src/configs/injector/injector.dart';
import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_current_assignment_reponse.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/features/bulk_orders/bloc/current_assignment_orders_bloc/current_assignment_orders_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_current_assignment_bloc/order_current_assignment_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_list_bloc/order_list_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_status_update_bloc/order_status_update_bloc.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/current_assignment_order_list_response.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';

class BulkOrderScreen extends StatefulWidget {
  final AssignmentBatch? assignment;
  final bool isFromTab;

  const BulkOrderScreen({
    super.key,
    this.assignment,
    this.isFromTab = false,
  });

  @override
  State<BulkOrderScreen> createState() => _BulkOrderScreenState();
}

class _BulkOrderScreenState extends State<BulkOrderScreen> with SingleTickerProviderStateMixin {
  AssignmentBatch? _assignment;
  bool _isStatusUpdating = false;
  late final AnimationController _animController;
  int _prevBulkOrdersLength = 0;
  int _prevActiveIndex = -2;

  @override
  void initState() {
    super.initState();
    _assignment = widget.assignment;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _statusLabel(Order order, String raw) {
    switch (raw.toUpperCase()) {
      case 'DEL_ACCEPTED':
        return 'DELIVERY ACCEPTED';
      case 'ON_THE_WAY':
        return 'ON THE WAY';
      case 'PICKED_UP':
        return 'PICKED UP';
      case 'READY_FOR_PICKUP':
        return 'READY FOR PICK UP';
      case 'PREPARING':
        return 'PREPARING';
      case 'DELIVERED':
        return 'DELIVERED';
      case 'ACCEPTED':
        return 'ACCEPTED';
      case 'PLACED':
        return 'PLACED';
      case 'PENDING':
        return 'PENDING';
      case 'ASSIGNED':
        return 'ASSIGNED';
      default:
        return raw.isNotEmpty ? raw : (order.isAssigned ? 'ASSIGNED' : 'PENDING');
    }
  }

  Color _badgeBg(String raw) {
    switch (raw.toUpperCase()) {
      case 'DEL_ACCEPTED':
        return const Color(0xFFE0F2FE);
      case 'ON_THE_WAY':
        return const Color(0xFFEDE9FE);
      case 'PICKED_UP':
        return const Color(0xFFEDE9FE);
      case 'READY_FOR_PICKUP':
        return const Color(0xFFFEF9C3);
      case 'PREPARING':
        return const Color(0xFFFEF9C3);
      case 'DELIVERED':
        return const Color(0xFFDCFCE7);
      case 'ACCEPTED':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFFFF2E6);
    }
  }

  Color _badgeFg(String raw) {
    switch (raw.toUpperCase()) {
      case 'DEL_ACCEPTED':
        return const Color(0xFF0284C7);
      case 'ON_THE_WAY':
        return const Color(0xFF7C3AED);
      case 'PICKED_UP':
        return const Color(0xFF7C3AED);
      case 'READY_FOR_PICKUP':
        return const Color(0xFFCA8A04);
      case 'PREPARING':
        return const Color(0xFFCA8A04);
      case 'DELIVERED':
        return const Color(0xFF16A34A);
      case 'ACCEPTED':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFFFA6624);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<CurrentAssignmentOrdersBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<OrderCurrentAssignmentBloc>()..add(const OrderCurrentAssignmentGetEvent()),
        ),
        BlocProvider(
          create: (_) => getIt<OrderStatusUpdateBloc>(),
        ),
      ],
      child: BlocBuilder<CurrentAssignmentOrdersBloc, CurrentAssignmentOrdersState>(
        builder: (context, ordersState) {
          List<Order> bulkOrders = [];
          if (ordersState is CurrentAssignmentOrdersSuccessState) {
            bulkOrders = ordersState.data.data.map((e) => e.toOrder()).toList();
          }

          return Scaffold(
            backgroundColor: const Color(0xFFFFF9F5),
            appBar: _buildAppBar(context, bulkOrders),
            body: Stack(
              children: [
                MultiBlocListener(
                  listeners: [
                    BlocListener<OrderCurrentAssignmentBloc, OrderCurrentAssignmentState>(
                      listener: (context, state) {
                        if (state is OrderCurrentAssignmentSuccessState) {
                          setState(() {
                            _assignment = state.data.data;
                          });
                          if (state.data.data != null) {
                            context.read<CurrentAssignmentOrdersBloc>().add(
                                  CurrentAssignmentOrdersGetEvent(state.data.data!.uuid, 1, 100),
                                );
                          }
                        }
                      },
                    ),
                    BlocListener<CurrentAssignmentOrdersBloc, CurrentAssignmentOrdersState>(
                      listener: (context, state) {
                        if (state is CurrentAssignmentOrdersFailureState) {
                          appSnackBar(context, AppColor.bright_red, state.message);
                        }
                      },
                    ),
                    BlocListener<OrderStatusUpdateBloc, OrderStatusUpdateState>(
                      listener: (context, state) {
                        if (state is OrderStatusUpdateLoadingState) {
                          setState(() {
                            _isStatusUpdating = true;
                          });
                        } else if (state is OrderStatusUpdateSuccessState) {
                          setState(() {
                            _isStatusUpdating = false;
                          });
                          appSnackBar(
                            context,
                            AppColor.green,
                            state.data.message.isNotEmpty ? state.data.message : 'Status updated',
                          );
                          context.read<OrderCurrentAssignmentBloc>().add(
                                const OrderCurrentAssignmentGetEvent(),
                              );
                        } else if (state is OrderStatusUpdateFailureState) {
                          setState(() {
                            _isStatusUpdating = false;
                          });
                          appSnackBar(context, AppColor.bright_red, state.message);
                        }
                      },
                    ),
                  ],
                  child: Builder(
                    builder: (context) {
                      final currentAssignmentState = context.watch<OrderCurrentAssignmentBloc>().state;
                      if (currentAssignmentState is OrderCurrentAssignmentLoadingState ||
                          currentAssignmentState is OrderCurrentAssignmentInitialState) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColor.darkOrange),
                        );
                      }

                      if (_assignment == null || _assignment!.orderCount == 0 || _assignment!.orderIds.isEmpty) {
                        return RefreshIndicator(
                          color: AppColor.darkOrange,
                          onRefresh: () async {
                            context.read<OrderCurrentAssignmentBloc>().add(
                                  const OrderCurrentAssignmentGetEvent(),
                                );
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              height: MediaQuery.of(context).size.height - 180,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppColor.orangeTint.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 64,
                                      color: AppColor.darkOrange,
                                    ),
                                  ),
                                  20.hS,
                                  const Text(
                                    'No orders found',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.charcoal,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final isLoading = ordersState is CurrentAssignmentOrdersLoadingState && bulkOrders.isEmpty;

                      if (isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColor.darkOrange),
                        );
                      }

                      if (bulkOrders.isEmpty) {
                        return RefreshIndicator(
                          color: AppColor.darkOrange,
                          onRefresh: () async {
                            context.read<OrderCurrentAssignmentBloc>().add(
                                  const OrderCurrentAssignmentGetEvent(),
                                );
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              height: MediaQuery.of(context).size.height - 180,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppColor.orangeTint.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.local_shipping_outlined,
                                      size: 64,
                                      color: AppColor.darkOrange,
                                    ),
                                  ),
                                  20.hS,
                                  const Text(
                                    'No active orders found in this assignment',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.charcoal,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // Compute the active card dynamically (first non-completed order)
                      final activeIndex = bulkOrders.indexWhere((o) {
                        final status = o.orderStatus.toUpperCase();
                        return status != 'DELIVERED' && status != 'REJECTED';
                      });

                      // Check if we need to start/restart the animation
                      if (bulkOrders.isNotEmpty &&
                          (_prevBulkOrdersLength != bulkOrders.length ||
                              _prevActiveIndex != activeIndex)) {
                        _prevBulkOrdersLength = bulkOrders.length;
                        _prevActiveIndex = activeIndex;
                        _animController.reset();
                        _animController.forward();
                      }

                      final targetActiveIndex = activeIndex == -1 ? bulkOrders.length - 1 : activeIndex;
                      final double totalSteps = (2 * targetActiveIndex + 1).toDouble();

                      return RefreshIndicator(
                        color: AppColor.darkOrange,
                        onRefresh: () async {
                          context.read<OrderCurrentAssignmentBloc>().add(
                                const OrderCurrentAssignmentGetEvent(),
                              );
                        },
                        child: AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: bulkOrders.length,
                              itemBuilder: (context, index) {
                                final order = bulkOrders[index];

                                final bool isActive = index == (activeIndex == -1 ? 0 : activeIndex);

                                final bool prevDelivered = index > 0 && bulkOrders[index - 1].orderStatus.toUpperCase() == 'DELIVERED';
                                final bool currentDelivered = bulkOrders[index].orderStatus.toUpperCase() == 'DELIVERED';

                                // Calculate progress for line
                                double lineProgress = 0.0;
                                if (index > 0 && prevDelivered && currentDelivered && totalSteps > 0) {
                                  final double start = (2 * index - 1) / totalSteps;
                                  final double end = (2 * index) / totalSteps;
                                  if (_animController.value >= end) {
                                    lineProgress = 1.0;
                                  } else if (_animController.value <= start) {
                                    lineProgress = 0.0;
                                  } else {
                                    lineProgress = Curves.easeInOut.transform((_animController.value - start) / (end - start));
                                  }
                                }

                                // Calculate progress for card border
                                double cardProgress = 0.0;
                                if (currentDelivered && totalSteps > 0) {
                                  final double start = (2 * index) / totalSteps;
                                  final double end = (2 * index + 1) / totalSteps;
                                  if (_animController.value >= end) {
                                    cardProgress = 1.0;
                                  } else if (_animController.value <= start) {
                                    cardProgress = 0.0;
                                  } else {
                                    cardProgress = Curves.easeInOut.transform((_animController.value - start) / (end - start));
                                  }
                                }

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (index > 0)
                                      Center(
                                        child: Container(
                                          width: 6, // Thick connector
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Color.lerp(Colors.grey.shade300, AppColor.darkOrange, lineProgress),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                      ),
                                    _buildOrderCard(context, order, isActive, index, activeIndex, cardProgress),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (_isStatusUpdating)
                  Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColor.darkOrange),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, List<Order> bulkOrders) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColor.darkOrange,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (!widget.isFromTab)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              Center(
                child: Text(
                  'my_orders'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (_assignment != null && bulkOrders.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () {
                        context.push(AppRoute.map.path, extra: bulkOrders);
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
                        child: Transform.rotate(
                          angle: math.pi / 4, // 45° towards upper-right
                          child: const Icon(
                            Icons.navigation,
                            color: AppColor.darkOrange,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, bool isActive, int index, int activeIndex, double cardProgress) {
    final String displayId = order.uuId.isNotEmpty
        ? '#${order.uuId.substring(0, order.uuId.length > 8 ? 8 : order.uuId.length)}'
        : '#ORD-${order.id}';

    final String rawStatus = order.orderStatus;
    final String upperStatus = rawStatus.toUpperCase();
    final bool isCompleted = upperStatus == 'DELIVERED' || upperStatus == 'REJECTED';
    final String statusLabel = _statusLabel(order, rawStatus);
    final Color badgeBg = _badgeBg(rawStatus);
    final Color badgeFg = _badgeFg(rawStatus);
    final String customer = order.customerName.isNotEmpty ? order.customerName : order.deliveryName;
    final String timeStr = order.slotStartTime.isNotEmpty
        ? '${order.slotStartTime} - ${order.slotEndTime}'
        : order.deliveryDate;

    return GestureDetector(
      onTap: () {
        context.push(AppRoute.orderDetails.path, extra: order);
      },
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Color.lerp(Colors.grey.shade200, AppColor.darkOrange, cardProgress)!,
          width: 1.0 + cardProgress,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayId,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D121F),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: badgeFg,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          10.hS,
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          10.hS,
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF2E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.store_rounded, color: Color(0xFFFA6624), size: 20),
              ),
              12.wS,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.isNotEmpty ? customer : 'delivery_order'.tr(),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    2.hS,
                    Text(
                      '${order.totalItems} ${'items'.tr()} • ₹${order.grandTotal}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          10.hS,
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Color(0xFFFA6624), size: 16),
              6.wS,
              Expanded(
                child: Text(
                  order.deliveryAddress.isNotEmpty
                      ? order.deliveryAddress
                      : 'delivery_address_not_specified'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (timeStr.isNotEmpty) ...[
                8.wS,
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          if (isActive && !isCompleted) ...[
            16.hS,
            Builder(
              builder: (context) {
                final bool isDeliveredState = upperStatus == 'ON_THE_WAY';

                final String btnText = isDeliveredState ? 'DELIVERED' : 'ON THE WAY';
                final IconData btnIcon = isDeliveredState ? Icons.check_circle_rounded : Icons.delivery_dining_rounded;

                final bool isButtonActive = upperStatus == 'PICKED_UP' || upperStatus == 'ON_THE_WAY';
                final String targetStatus = upperStatus == 'PICKED_UP' ? 'ON_THE_WAY' : 'DELIVERED';

                return SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: isButtonActive
                        ? () {
                            context.read<OrderStatusUpdateBloc>().add(
                                  OrderStatusUpdateGetEvent(
                                    order.uuId,
                                    targetStatus,
                                    null,
                                  ),
                                );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonActive ? AppColor.darkOrange : Colors.grey.shade300,
                      foregroundColor: isButtonActive ? Colors.white : Colors.grey.shade500,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade500,
                      elevation: isButtonActive ? 3 : 0,
                      shadowColor: isButtonActive ? AppColor.darkOrange.withValues(alpha: 0.4) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(btnIcon, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          btnText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          ],
        ],
      ),
      ),
    );
  }
}
