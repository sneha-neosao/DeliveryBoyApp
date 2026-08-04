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

  String _getFilterLabel(String filterName) {
    switch (filterName) {
      case 'All':
        return 'all'.tr();
      case 'Active':
        return 'active'.tr();
      case 'Completed':
        return 'completed'.tr();
      default:
        return filterName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Main content (header always visible + body) ─────────────
        Column(
          children: [
            // Screen Header — always visible regardless of state
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'my_orders'.tr(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColor.white,
                          ),
                        ),
                        // Count badge hidden while loading
                        if (!isLoadingInitial)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF2E6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${filteredOrders.length} ${'orders'.tr()}',
                              style: const TextStyle(
                                color: Color(0xFFFA6624),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    12.hS,
                    // Status Filter Chips
                    Row(
                      children: [
                        _buildFilterChip('All'),
                        8.wS,
                        _buildFilterChip('Active'),
                        8.wS,
                        _buildFilterChip('Completed'),
                      ],
                    ),
                  ],
                ),
              )
            ),

            // Body area below the header
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),

        // ── GIF loader overlay (only during initial load) ───────────
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
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/no_order_bg.png',
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.inbox_rounded,
                  size: 64,
                  color: AppColor.slateGrey,
                ),
              ),
              12.hS,
              Text(
                'no_orders_found'.tr(),
                style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
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

  Widget _buildFilterChip(String filterName) {
    final bool isSelected = selectedFilter == filterName;
    return GestureDetector(
      onTap: () => onFilterChanged(filterName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFA6624)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _getFilterLabel(filterName),
          style: TextStyle(
            color:
                isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
