import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_list_bloc/order_list_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/order_list_card_widget.dart';
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

  const OrderListView({
    super.key,
    required this.filteredOrders,
    required this.state,
    required this.scrollController,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  Map<String, List<Order>> _groupOrdersByDate(List<Order> orders) {
    final Map<String, List<Order>> groups = {};
    for (final order in orders) {
      final key = order.deliveryDate.isNotEmpty
          ? order.deliveryDate
          : 'today'.tr();
      groups.putIfAbsent(key, () => []).add(order);
    }
    return groups;
  }

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
    final groupedMap = _groupOrdersByDate(filteredOrders);

    return SafeArea(
      child: RefreshIndicator(
        color: AppColor.darkOrange,
        onRefresh: () async {
          context.read<OrderListBloc>().add(const GetOrderListEvent(page: 1, isRefresh: true));
        },
        child: Column(
          children: [
            // Screen Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
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
                          color: Color(0xFF0D121F),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  // Status Filter Segmented Control
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
            ),

            // Date-Grouped Orders List
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(
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
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: groupedMap.keys.length + (state.loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == groupedMap.keys.length) {
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

                        final dateHeader = groupedMap.keys.elementAt(index);
                        final ordersInGroup = groupedMap[dateHeader]!;

                        final isToday = dateHeader == 'Today' || dateHeader == 'today'.tr();
                        final isYesterday = dateHeader == 'Yesterday' || dateHeader == 'yesterday'.tr();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Group Heading
                            Padding(
                              padding: const EdgeInsets.only(top: 12, bottom: 8, left: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    isToday
                                        ? Icons.today_rounded
                                        : isYesterday
                                            ? Icons.history_rounded
                                            : Icons.calendar_today_rounded,
                                    size: 16,
                                    color: const Color(0xFFFA6624),
                                  ),
                                  6.wS,
                                  Text(
                                    isToday ? 'today'.tr() : (isYesterday ? 'yesterday'.tr() : dateHeader),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D121F),
                                    ),
                                  ),
                                  8.wS,
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${ordersInGroup.length}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Order Item Cards
                            ...ordersInGroup.map((order) => OrderListCardWidget(order: order)),
                          ],
                        );
                      },
                    ),
            ),
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFA6624) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _getFilterLabel(filterName),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
