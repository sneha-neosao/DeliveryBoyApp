import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_assignment_bloc/order_assignment_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_details_bloc/order_details_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/delivery_address_card_widget.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/order_details_widget.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/order_items_listview.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/payment_info_card_widget.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/status_history_card.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_details_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_list_response.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order? order;

  const OrderDetailsScreen({
    super.key,
    this.order,
  });

  @override
  Widget build(BuildContext context) {
    if (order == null) {
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
        BlocProvider(
          create: (context) =>
              getIt<OrderDetailsBloc>()..add(OrderDetailsGetEvent(order!.uuId)),
        ),
        BlocProvider(
          create: (context) => getIt<OrderAssignmentBloc>(),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF9F5),
        body: SafeArea(
          child: BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
            builder: (context, state) {
              if (state is OrderDetailsLoadingState || state is OrderDetailsInitialState) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.darkOrange,
                  ),
                );
              } else if (state is OrderDetailsFailureState) {
                return Center(
                  child: Padding(
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
                            context.read<OrderDetailsBloc>().add(OrderDetailsGetEvent(order!.uuId));
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
                );
              } else if (state is OrderDetailsSuccessState) {
                final orderDetails = state.data.data;
                if (orderDetails == null) {
                  return Center(
                    child: Text('no_order_details_found'.tr()),
                  );
                }
                return _OrderDetailsView(orderDetails: orderDetails, fallbackOrder: order!);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

// ─── Collapsible header constants ────────────────────────────────────────────
// Expanded orange bar height (reduced from 180)
const double _kExpandedHeaderH = 130.0;
// Collapsed orange bar height (back arrow + ID only)
const double _kCollapsedHeaderH = 62.0;
// How many pixels of scroll trigger a full collapse
const double _kCollapseScrollRange = 90.0;
// Space for the circle avatar that peeks below the orange bar
const double _kCircleGap = 65.0;

class _OrderDetailsView extends StatefulWidget {
  final OrderDetails orderDetails;
  final Order fallbackOrder;

  const _OrderDetailsView({
    required this.orderDetails,
    required this.fallbackOrder,
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

  /// 0.0 = fully expanded  →  1.0 = fully collapsed
  double get _progress => _scrollOffset / _kCollapseScrollRange;

  double get _headerH =>
      _kExpandedHeaderH + (_kCollapsedHeaderH - _kExpandedHeaderH) * _progress;

  /// Items that only show when expanded (circle, status badge, gap)
  double get _expandedFade => 1.0 - _progress;

  /// Bottom corners always stay curved
  static const double _radius = 24.0;

  /// Only the 55 px the circle physically extends below the orange bar
  double get _circleOverlapH => 55.0 * _expandedFade;

  @override
  Widget build(BuildContext context) {
    final orderDetails = widget.orderDetails;
    final fallbackOrder = widget.fallbackOrder;

    return BlocListener<OrderAssignmentBloc, OrderAssignmentState>(
      listener: (context, state) {
        if (state is OrderAssignmentLoadingState) {
          setState(() => _isLoading = true);
        } else if (state is OrderAssignmentSuccessState) {
          setState(() => _isLoading = false);
          appSnackBar(context, AppColor.green, state.data.message.isNotEmpty
              ? state.data.message
              : 'order_accepted'.tr());
          context.pop();
        } else if (state is OrderAssignmentFailureState) {
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
              child: const Center(
                child: CircularProgressIndicator(color: AppColor.darkOrange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final orderDetails = widget.orderDetails;
    final fallbackOrder = widget.fallbackOrder;

    final String displayId = orderDetails.uuId.isNotEmpty
        ? '#${orderDetails.uuId.substring(0, orderDetails.uuId.length > 8 ? 8 : orderDetails.uuId.length)}'
        : '#ORD-${orderDetails.id}';
    final String customerName = orderDetails.deliveryDetails?.name.isNotEmpty == true
        ? orderDetails.deliveryDetails!.name
        : (orderDetails.customerName.isNotEmpty ? orderDetails.customerName : fallbackOrder.customerName);
    final String customerPhone = orderDetails.deliveryDetails?.phone.isNotEmpty == true
        ? orderDetails.deliveryDetails!.phone
        : (orderDetails.customerContact.isNotEmpty ? orderDetails.customerContact : fallbackOrder.customerContact);
    final String deliveryAddress = orderDetails.deliveryDetails?.address.isNotEmpty == true
        ? orderDetails.deliveryDetails!.address
        : (fallbackOrder.deliveryAddress.isNotEmpty
            ? fallbackOrder.deliveryAddress
            : 'address_not_available'.tr());

    return Column(
      children: [
        // ── Collapsible pinned header ──────────────────────────────────────
        SizedBox(
          height: _headerH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Orange background
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

              // Back arrow — always visible
              Positioned(
                top: 12,
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
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),

              // Order ID — always visible, stays centered in current header height
              Positioned.fill(
                child: Padding(
                  // Fades away when collapsed so ID stays perfectly centred in the sticky bar
                  padding: EdgeInsets.only(bottom: 28 * _expandedFade),
                  child: Center(
                    child: Text(
                      displayId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Circle avatar — fades & slides away as header collapses
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
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF2E6),
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/vege_grocery.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.shopping_basket_rounded,
                                  color: AppColor.darkOrange,
                                  size: 48,
                                ),
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

        // ── Circle overflow gap — collapses to 0 when header collapses ───────
        // Only covers the 55 px the circle avatar overflows below the orange bar.
        // The status badge lives inside the scroll view so it never overlaps.
        SizedBox(height: _circleOverlapH),

        // ── Scrollable content ─────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            controller: _sc,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  12.hS,
                  // Status badge — sits below circle, scrolls away naturally
                  Builder(
                    builder: (_) {
                      // Resolve badge colors from order status
                      final Color bgColor;
                      final Color textColor;
                      switch (orderDetails.orderStatus.toUpperCase()) {
                        case 'PLACED':
                        case 'PENDING':
                          bgColor = const Color(0xFFDBEAFE);   // light blue
                          textColor = const Color(0xFF2563EB);  // blue
                          break;
                        case 'ACCEPTED':
                        case 'DELIVERED':
                          bgColor = const Color(0xFFDCFCE7);   // light green
                          textColor = const Color(0xFF16A34A);  // green
                          break;
                        case 'PREPARING':
                          bgColor = const Color(0xFFFEF9C3);   // light yellow
                          textColor = const Color(0xFFCA8A04);  // amber
                          break;
                        case 'PICKED_UP':
                          bgColor = const Color(0xFFEDE9FE);   // light purple
                          textColor = const Color(0xFF7C3AED);  // purple
                          break;
                        case 'ON_THE_WAY':
                          bgColor = const Color(0xFFDBEAFE);   // light indigo-blue
                          textColor = const Color(0xFF3B82F6);  // indigo-blue
                          break;
                        default:
                          bgColor = const Color(0xFFFFF2E6);   // default orange tint
                          textColor = AppColor.darkOrange;
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          orderDetails.orderStatus.isNotEmpty
                              ? orderDetails.orderStatus
                              : 'single_order'.tr(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  16.hS,
                  // Delivery address card
                  DeliveryAddressCardWidget(
                    customerName: customerName,
                    customerPhone: customerPhone,
                    deliveryAddress: deliveryAddress,
                  ),
                  16.hS,
                  // Order metrics + time info
                  OrderDetailsWidget(orderDetails: orderDetails),
                  16.hS,
                  // Order items list
                  if (orderDetails.items.isNotEmpty) ...[
                    OrderItemsListview(items: orderDetails.items),
                    16.hS,
                  ],
                  // Payment breakdown
                  PaymentInfoCardWidget(orderDetails: orderDetails),
                  16.hS,
                  // Status history timeline
                  if (orderDetails.statusLogs.isNotEmpty) ...[
                    StatusHistoryCard(statusLogs: orderDetails.statusLogs),
                  ],
                  24.hS,
                ],
              ),
            ),
          ),
        ),

        // ── Sticky bottom buttons (only shown when order is PREPARING) ─────
        if (orderDetails.orderStatus == 'PREPARING')
          Container(
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
            child: Row(
              children: [
                // Reject button
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => _showRejectDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.bright_red,
                        side: const BorderSide(color: AppColor.bright_red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'reject'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ),
                12.wS,
                // Accept button
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.read<OrderAssignmentBloc>().add(
                                OrderAssignmentGetEvent(
                                  orderDetails.uuId,
                                  'accept',
                                  null,
                                ),
                              ),
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
                          Text(
                            'accept_order'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

      ],
    );
  }

  // ── Reject dialog ──────────────────────────────────────────────────────────
  void _showRejectDialog(BuildContext context) {
    final TextEditingController _reasonCtrl = TextEditingController();
    final _formKey = GlobalKey<FormState>();

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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
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
                      12.wS,
                      Text(
                        'reject_order'.tr(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  16.hS,
                  // Reason text field
                  TextFormField(
                    controller: _reasonCtrl,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'enter_rejection_reason'.tr(),
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColor.bright_red, width: 1.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColor.bright_red, width: 1.5),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'please_enter_reason'.tr();
                      }
                      return null;
                    },
                  ),
                  20.hS,
                  // Submit button — right-aligned, styled like Accept
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          final reason = _reasonCtrl.text.trim();
                          Navigator.of(dialogCtx).pop();
                          context.read<OrderAssignmentBloc>().add(
                                OrderAssignmentGetEvent(
                                  widget.orderDetails.uuId,
                                  'reject',
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
                          elevation: 3,
                          shadowColor: AppColor.darkOrange.withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'submit'.tr(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
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
    ).then((_) => _reasonCtrl.dispose());
  }
}
