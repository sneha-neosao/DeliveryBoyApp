import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_list_bloc/order_list_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/order_list_card_widget.dart';
import 'package:delivery_boy_app/src/features/widgets/gif_loader_overlay.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_list_response.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderListView extends StatelessWidget {
  final List<Order> filteredOrders;
  final OrderListState state;
  final ScrollController scrollController;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final bool isLoadingInitial;
  final bool isError;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const OrderListView({
    super.key,
    required this.filteredOrders,
    required this.state,
    required this.scrollController,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.isLoadingInitial = false,
    this.isError = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBody(context),
        if (isLoadingInitial) const GifLoaderOverlay(),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    // Error state with no cached orders
    if (isError) {
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
              12.hS,
              Text(
                errorMessage ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.charcoal,
                ),
              ),
              16.hS,
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.darkOrange,
                  foregroundColor: AppColor.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    // Empty list state
    if (filteredOrders.isEmpty) {
      String emptyTextKey = 'no_orders_yet';
      String emptySubtitleKey = 'home_no_orders_subtitle';
      IconData emptyIcon = Icons.shopping_bag_outlined;

      if (selectedFilter == 'Active') {
        emptyTextKey = 'no_active_orders';
        emptySubtitleKey = 'no_active_orders_subtitle';
        emptyIcon = Icons.local_shipping_outlined;
      } else if (selectedFilter == 'Completed') {
        emptyTextKey = 'no_delivered_orders';
        emptySubtitleKey = 'no_delivered_orders_subtitle';
        emptyIcon = Icons.assignment_turned_in_outlined;
      }

      return RefreshIndicator(
        color: AppColor.darkOrange,
        onRefresh: () async {
          context.read<OrderListBloc>().add(
              const GetOrderListEvent(page: 1, isRefresh: true));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height - 220,
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
                  child: Icon(
                    emptyIcon,
                    size: 64,
                    color: AppColor.darkOrange,
                  ),
                ),
                20.hS,
                Text(
                  emptyTextKey.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.charcoal,
                    height: 1.4,
                  ),
                ),
                8.hS,
                Text(
                  emptySubtitleKey.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Normal scrollable flat list with pull-to-refresh
    return RefreshIndicator(
      color: AppColor.darkOrange,
      onRefresh: () async {
        context.read<OrderListBloc>().add(
            const GetOrderListEvent(page: 1, isRefresh: true));
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: ListView.builder(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: filteredOrders.length + (state.loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Load-more spinner at the bottom
            if (index == filteredOrders.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColor.darkOrange,
                    strokeWidth: 2.5,
                  ),
                ),
              );
            }
            return OrderListCardWidget(order: filteredOrders[index]);
          },
        ),
      ),
    );
  }

}
