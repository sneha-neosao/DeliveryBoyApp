import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/order_details_shimmer_widget.dart';
import 'package:delivery_boy_app/src/features/bulk_orders/bloc/current_assignment_orders_bloc/current_assignment_orders_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_assignment_bloc/order_assignment_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_status_update_bloc/order_status_update_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_details_bloc/order_details_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/delivery_address_card_widget.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/order_details_widget.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/order_items_listview.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/payment_info_card_widget.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/status_history_card.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_details_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/food_order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BulkOrderDetailsScreen extends StatefulWidget {
  final Order? order;
  final String? orderUuid;
  final String? assignmentUuid;

  const BulkOrderDetailsScreen({
    super.key,
    this.order,
    this.orderUuid,
    this.assignmentUuid,
  });

  @override
  State<BulkOrderDetailsScreen> createState() => _BulkOrderDetailsScreenState();
}

class _BulkOrderDetailsScreenState extends State<BulkOrderDetailsScreen> {
  Order? _order;
  String? _subOrderUuid;
  late final CurrentAssignmentOrdersBloc _currentAssignmentOrdersBloc;
  late final OrderDetailsBloc _orderDetailsBloc;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _subOrderUuid = widget.order?.uuId ?? widget.orderUuid;
    _currentAssignmentOrdersBloc = getIt<CurrentAssignmentOrdersBloc>();
    _orderDetailsBloc = getIt<OrderDetailsBloc>();

    if (_subOrderUuid != null && _subOrderUuid!.isNotEmpty) {
      _orderDetailsBloc.add(OrderDetailsGetEvent(_subOrderUuid!));
    } else if (widget.assignmentUuid != null && widget.assignmentUuid!.isNotEmpty) {
      // First call order API for current assignment
      _currentAssignmentOrdersBloc.add(
        CurrentAssignmentOrdersGetEvent(widget.assignmentUuid!, 1, 10),
      );
    }
  }

  @override
  void dispose() {
    _orderDetailsBloc.close();
    _currentAssignmentOrdersBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_subOrderUuid == null && (widget.assignmentUuid == null || widget.assignmentUuid!.isEmpty)) {
      return Scaffold(
        appBar: AppBar(
          title: Text('order_details'.tr()),
          backgroundColor: AppColor.darkOrange,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('no_order_details_found'.tr()),
              16.hS,
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text('go_back'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _orderDetailsBloc),
        BlocProvider.value(value: _currentAssignmentOrdersBloc),
        BlocProvider(create: (_) => getIt<OrderAssignmentBloc>()),
        BlocProvider(create: (_) => getIt<OrderStatusUpdateBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<CurrentAssignmentOrdersBloc, CurrentAssignmentOrdersState>(
            listener: (context, state) {
              if (state is CurrentAssignmentOrdersSuccessState && state.data.data.isNotEmpty) {
                final firstOrderData = state.data.data.first;
                setState(() {
                  _order = firstOrderData.toOrder();
                  _subOrderUuid = firstOrderData.uuId;
                });
                // Using that suborder uuid, call details API
                _orderDetailsBloc.add(OrderDetailsGetEvent(firstOrderData.uuId));
              } else if (state is CurrentAssignmentOrdersFailureState) {
                appSnackBar(context, AppColor.bright_red, state.message);
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFFFFF9F5),
          body: SafeArea(
            top: false,
            child: BlocBuilder<CurrentAssignmentOrdersBloc, CurrentAssignmentOrdersState>(
              builder: (context, currentOrdersState) {
                if (currentOrdersState is CurrentAssignmentOrdersLoadingState && _subOrderUuid == null) {
                  return const OrderDetailsShimmerWidget();
                }

                if (currentOrdersState is CurrentAssignmentOrdersFailureState && _subOrderUuid == null) {
                  return RefreshIndicator(
                    color: AppColor.darkOrange,
                    onRefresh: () async {
                      if (widget.assignmentUuid != null) {
                        _currentAssignmentOrdersBloc.add(
                          CurrentAssignmentOrdersGetEvent(widget.assignmentUuid!, 1, 10),
                        );
                      }
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height - 100,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AppColor.bright_red,
                            ),
                            16.hS,
                            Text(
                              'failed_load_details'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            8.hS,
                            Text(
                              currentOrdersState.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            24.hS,
                            ElevatedButton(
                              onPressed: () {
                                if (widget.assignmentUuid != null) {
                                  _currentAssignmentOrdersBloc.add(
                                    CurrentAssignmentOrdersGetEvent(widget.assignmentUuid!, 1, 10),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.darkOrange,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('retry'.tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
                  builder: (context, state) {
                    if (state is OrderDetailsLoadingState || state is OrderDetailsInitialState) {
                      return const OrderDetailsShimmerWidget();
                    } else if (state is OrderDetailsFailureState) {
                      return RefreshIndicator(
                        color: AppColor.darkOrange,
                        onRefresh: () async {
                          if (_subOrderUuid != null) {
                            _orderDetailsBloc.add(OrderDetailsGetEvent(_subOrderUuid!));
                          }
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height - 100,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 48,
                                  color: AppColor.bright_red,
                                ),
                                16.hS,
                                Text(
                                  'failed_load_details'.tr(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                8.hS,
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                24.hS,
                                ElevatedButton(
                                  onPressed: () {
                                    if (_subOrderUuid != null) {
                                      _orderDetailsBloc.add(OrderDetailsGetEvent(_subOrderUuid!));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.darkOrange,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('retry'.tr()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else if (state is OrderDetailsSuccessState) {
                      final orderDetails = state.data.data;
                      if (orderDetails == null) {
                        return Center(
                          child: Text('no_order_details_found'.tr()),
                        );
                      }
                      return _OrderDetailsView(orderDetails: orderDetails, fallbackOrder: _order);
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Collapsible header constants ────────────────────────────────────────────
const double _kExpandedHeaderH = 130.0;
const double _kCollapsedHeaderH = 62.0;
const double _kCollapseScrollRange = 90.0;

class _OrderDetailsView extends StatefulWidget {
  final OrderDetails orderDetails;
  final Order? fallbackOrder;

  const _OrderDetailsView({
    required this.orderDetails,
    this.fallbackOrder,
  });

  @override
  State<_OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<_OrderDetailsView> {
  final ScrollController _sc = ScrollController();
  double _scrollOffset = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sc.addListener(_onScroll);
  }

  @override
  void dispose() {
    _sc.removeListener(_onScroll);
    _sc.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _sc.offset.clamp(0.0, _kCollapseScrollRange);
    if (offset != _scrollOffset) setState(() => _scrollOffset = offset);
  }

  double get _progress => _scrollOffset / _kCollapseScrollRange;
  double get _headerH => _kExpandedHeaderH + (_kCollapsedHeaderH - _kExpandedHeaderH) * _progress;
  double get _expandedFade => 1.0 - _progress;
  static const double _radius = 24.0;
  double get _circleOverlapH => 55.0 * _expandedFade;

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PLACED': return 'PLACED';
      case 'PENDING': return 'PENDING';
      case 'ACCEPTED': return 'ACCEPTED';
      case 'DEL_ACCEPTED': return 'DELIVERY ACCEPTED';
      case 'PREPARING': return 'PREPARING';
      case 'READY_FOR_PICKUP': return 'READY FOR PICK UP';
      case 'PICKED_UP': return 'PICKED UP';
      case 'ON_THE_WAY': return 'ON THE WAY';
      case 'DELIVERED': return 'DELIVERED';
      case 'CANCELLED': return 'CANCELLED';
      case 'REJECTED': return 'REJECTED';
      default: return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderStatusUpdateBloc, OrderStatusUpdateState>(
      listener: (context, state) {
            if (state is OrderStatusUpdateLoadingState) {
              setState(() => _isLoading = true);
            } else if (state is OrderStatusUpdateSuccessState) {
              setState(() => _isLoading = false);
              appSnackBar(context, AppColor.green, state.data.message.isNotEmpty ? state.data.message : 'Status updated');
              // Stay on details screen and refresh the details API to show updated UI
              context.read<OrderDetailsBloc>().add(
                OrderDetailsGetEvent(widget.orderDetails.uuId),
              );
            } else if (state is OrderStatusUpdateFailureState) {
              setState(() => _isLoading = false);
              appSnackBar(context, AppColor.bright_red, state.message);
            }
      },
      child: Stack(
        children: [
          _buildBody(context),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(child: CircularProgressIndicator(color: AppColor.darkOrange)),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final orderDetails = widget.orderDetails;
    final fallbackOrder = widget.fallbackOrder;

    final String displayId = 'ORD_${orderDetails.id}';
    final String customerName = orderDetails.deliveryDetails?.name.isNotEmpty == true
        ? orderDetails.deliveryDetails!.name
        : (orderDetails.customerName.isNotEmpty
            ? orderDetails.customerName
            : (fallbackOrder?.customerName ?? ''));
    final String customerPhone = orderDetails.deliveryDetails?.phone.isNotEmpty == true
        ? orderDetails.deliveryDetails!.phone
        : (orderDetails.customerContact.isNotEmpty
            ? orderDetails.customerContact
            : (fallbackOrder?.customerContact ?? ''));
    final String deliveryAddress = orderDetails.deliveryDetails?.address.isNotEmpty == true
        ? orderDetails.deliveryDetails!.address
        : (fallbackOrder?.deliveryAddress.isNotEmpty == true
            ? fallbackOrder!.deliveryAddress
            : 'address_not_available'.tr());

    final bool isVendor = orderDetails.vendorId != null;

    final String? pickupName = isVendor
        ? (orderDetails.restaurantName?.isNotEmpty == true
            ? orderDetails.restaurantName
            : orderDetails.pickupDetails?.name)
        : (orderDetails.storeName?.isNotEmpty == true
            ? orderDetails.storeName
            : orderDetails.pickupDetails?.name);

    final String pickupAddress = isVendor
        ? (orderDetails.restaurantAddress?.isNotEmpty == true
            ? orderDetails.restaurantAddress!
            : (orderDetails.pickupDetails?.address.isNotEmpty == true
                ? orderDetails.pickupDetails!.address
                : ''))
        : (orderDetails.storeAddress?.isNotEmpty == true
            ? orderDetails.storeAddress!
            : (orderDetails.pickupDetails?.address.isNotEmpty == true
                ? orderDetails.pickupDetails!.address
                : ''));

    final String? pickupPhone = isVendor
        ? (orderDetails.restaurantPhone?.isNotEmpty == true
            ? orderDetails.restaurantPhone
            : orderDetails.pickupDetails?.phone)
        : orderDetails.pickupDetails?.phone;

    final double statusBarH = MediaQuery.of(context).padding.top;
    final double topShift = statusBarH * _progress;

    return Column(
      children: [
        SizedBox(
          height: _headerH + topShift,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.darkOrange,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(_radius),
                    bottomRight: Radius.circular(_radius),
                  ),
                ),
              ),
              // Back arrow — vertically aligned with order ID at all scroll states
              Positioned(
                top: topShift + (_headerH - 28 * _expandedFade) / 2 - 19,
                left: 12,
                child: InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
              // Order ID — shifts down when collapsed
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: topShift,
                    bottom: 28 * _expandedFade,
                  ),
                  child: Center(
                    child: Text(
                      displayId,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ),
              if (_expandedFade > 0)
                Positioned(
                  bottom: -55,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: _expandedFade,
                    child: Center(
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(color: Color(0xFFFFF2E6), shape: BoxShape.circle),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/vege_grocery_plate_img.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.shopping_basket_rounded, color: AppColor.darkOrange, size: 48),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: _circleOverlapH),
        Expanded(
          child: RefreshIndicator(
            color: AppColor.darkOrange,
            onRefresh: () async {
              context.read<OrderDetailsBloc>().add(OrderDetailsGetEvent(widget.orderDetails.uuId));
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              controller: _sc,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    12.hS,
                    Builder(
                      builder: (_) {
                        final Color bgColor;
                        final Color textColor;
                        switch (orderDetails.orderStatus.toUpperCase()) {
                          case 'PLACED':
                          case 'PENDING':
                            bgColor = const Color(0xFFDBEAFE);
                            textColor = const Color(0xFF2563EB);
                            break;
                          case 'ACCEPTED':
                          case 'DELIVERED':
                            bgColor = const Color(0xFFDCFCE7);
                            textColor = const Color(0xFF16A34A);
                            break;
                          case 'PREPARING':
                            bgColor = const Color(0xFFFEF9C3);
                            textColor = const Color(0xFFCA8A04);
                            break;
                          case 'PICKED_UP':
                            bgColor = const Color(0xFFEDE9FE);
                            textColor = const Color(0xFF7C3AED);
                            break;
                          case 'ON_THE_WAY':
                            bgColor = const Color(0xFFDBEAFE);
                            textColor = const Color(0xFF3B82F6);
                            break;
                          default:
                            bgColor = const Color(0xFFFFF2E6);
                            textColor = AppColor.darkOrange;
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            orderDetails.orderStatus.isNotEmpty ? _formatStatus(orderDetails.orderStatus) : 'single_order'.tr(),
                            style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                    16.hS,
                    Builder(
                      builder: (context) {
                        final autoAssignMode = (SessionManager.autoAssignModeNotifier.value ?? '').trim().toLowerCase().replaceAll('_', '-');
                        final bool isAutoAssign = autoAssignMode == 'auto-assign';

                        return DeliveryAddressCardWidget(
                          isVendor: isVendor,
                          pickupName: pickupName,
                          pickupAddress: pickupAddress,
                          pickupPhone: pickupPhone,
                          customerName: customerName,
                          customerPhone: customerPhone,
                          deliveryAddress: deliveryAddress,
                          showNavigationIcon: isAutoAssign,
                          onNavigationTap: () {
                            final double deliveryLat = orderDetails.deliveryDetails?.deliveryLat ??
                                widget.fallbackOrder?.deliveryLat ??
                                0.0;
                            final double deliveryLng = orderDetails.deliveryDetails?.deliveryLng ??
                                widget.fallbackOrder?.deliveryLng ??
                                0.0;
                            final double storeLat = orderDetails.storeLatitude ?? orderDetails.pickupDetails?.latitude ?? widget.fallbackOrder?.storeLatitude ?? 0.0;
                            final double storeLng = orderDetails.storeLongitude ?? orderDetails.pickupDetails?.longitude ?? widget.fallbackOrder?.storeLongitude ?? 0.0;

                            final Order effectiveOrder = widget.fallbackOrder ??
                                Order(
                                  id: orderDetails.id,
                                  uuId: orderDetails.uuId,
                                  orderStatus: orderDetails.orderStatus,
                                  paymentMode: orderDetails.paymentMode,
                                  paymentStatus: orderDetails.paymentStatus,
                                  grandTotal: orderDetails.grandTotal,
                                  platformCharges: orderDetails.platformCharges,
                                  totalItems: orderDetails.totalItems,
                                  customerName: customerName,
                                  customerContact: customerPhone,
                                  deliveryAddress: deliveryAddress,
                                  deliveryName: orderDetails.deliveryDetails?.name ?? '',
                                  deliveryPhone: orderDetails.deliveryDetails?.phone ?? '',
                                  deliveryPincode: orderDetails.deliveryDetails?.pincode ?? '',
                                  slotStartTime: orderDetails.slotStartTime,
                                  slotEndTime: orderDetails.slotEndTime,
                                  deliveryDate: orderDetails.deliveryDate,
                                  isAssigned: true,
                                  assignedDeliveryBoyId: 0,
                                  assignedDeliveryBoyName: '',
                                  assignedDeliveryBoyPhone: '',
                                  assignmentStatus: '',
                                  deliveryLat: deliveryLat,
                                  deliveryLng: deliveryLng,
                                  storeLatitude: storeLat,
                                  storeLongitude: storeLng,
                                );

                            context.push(
                              AppRoute.orderMap.path,
                              extra: [effectiveOrder],
                            );
                          },
                        );
                      },
                    ),
                    16.hS,
                    OrderDetailsWidget(orderDetails: orderDetails),
                    16.hS,
                    if (orderDetails.items.isNotEmpty) ...[
                      OrderItemsListview(items: orderDetails.items),
                      16.hS,
                    ],
                    PaymentInfoCardWidget(orderDetails: orderDetails),
                    16.hS,
                    if (orderDetails.statusLogs.isNotEmpty) ...[
                      StatusHistoryCard(statusLogs: orderDetails.statusLogs),
                    ],
                    24.hS,
                  ],
                ),
              ),
            ),
          ),
        ),
        // ── Sticky bottom area ─────────────────────────────────────────────
        // BULK / SLOT-WISE ORDERS:
        //   PICKED_UP  → active ON THE WAY button
        //   ON_THE_WAY → active DELIVERED button
        //   Any other status → no button
        if (orderDetails.orderStatus.toUpperCase() == 'PICKED_UP')
          _buildOnTheWayButton(context, orderDetails)
        else if (orderDetails.orderStatus.toUpperCase() == 'ON_THE_WAY')
          _buildDeliveredButton(context, orderDetails),
      ],
    );
  }

  // ── ON THE WAY button (shown when status is PICKED_UP) ────────────────────
  Widget _buildOnTheWayButton(BuildContext context, OrderDetails orderDetails) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  context.read<OrderStatusUpdateBloc>().add(
                    OrderStatusUpdateGetEvent(
                      orderDetails.uuId,
                      'ON_THE_WAY',
                      null,
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.darkOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 3,
            shadowColor: AppColor.darkOrange.withValues(alpha: 0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delivery_dining_rounded, size: 20),
              const SizedBox(width: 8),
              const Text(
                'ON THE WAY',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DELIVERED button (shown when status is PICKED_UP / ON_THE_WAY) ─────────
  Widget _buildDeliveredButton(BuildContext context, OrderDetails orderDetails) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  context.read<OrderStatusUpdateBloc>().add(
                    OrderStatusUpdateGetEvent(
                      orderDetails.uuId,
                      'DELIVERED',
                      null,
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.darkOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 3,
            shadowColor: AppColor.darkOrange.withValues(alpha: 0.4),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'DELIVERED',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

