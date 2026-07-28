import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_list_bloc/order_list_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/order_listview.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_list_response.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<OrderListBloc>()..add(const GetOrderListEvent(page: 1)),
        ),
      ],
      child: const _OrdersScreenContent(),
    );
  }
}

class _OrdersScreenContent extends StatefulWidget {
  const _OrdersScreenContent();

  @override
  State<_OrdersScreenContent> createState() => _OrdersScreenContentState();
}

class _OrdersScreenContentState extends State<_OrdersScreenContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  // Selected Filter Tab ('All', 'Active', 'Completed')
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final bloc = context.read<OrderListBloc>();
      final state = bloc.state;
      if (!state.loadingMore && !state.hasReachedMax && state is! OrderListLoadingState) {
        bloc.add(GetOrderListEvent(page: state.currentPage + 1));
      }
    }
  }

  List<Order> _getFilteredOrders(List<Order> allOrders) {
    if (_selectedFilter == 'Active') {
      return allOrders.where((o) {
        final status = o.orderStatus.toLowerCase();
        final assignStatus = o.assignmentStatus.toLowerCase();
        return status == 'assigned' || status == 'active' || assignStatus == 'assigned' || o.isAssigned;
      }).toList();
    } else if (_selectedFilter == 'Completed') {
      return allOrders.where((o) {
        final status = o.orderStatus.toLowerCase();
        return status == 'delivered' || status == 'completed';
      }).toList();
    }
    return allOrders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFFF9F5),
      body: BlocConsumer<OrderListBloc, OrderListState>(
        listener: (context, state) {
          if (state is OrderListFailureState) {
            appSnackBar(context, AppColor.bright_red, state.message);
          }
        },
        builder: (context, state) {
          final orders = state.orders ?? [];
          final isLoadingInitial = state is OrderListLoadingState && orders.isEmpty;

          if (isLoadingInitial) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColor.darkOrange,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'fetching_orders'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.slateGrey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is OrderListFailureState && orders.isEmpty) {
            return SafeArea(
              child: Center(
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
                        state.message,
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
                        onPressed: () {
                          context.read<OrderListBloc>().add(const GetOrderListEvent(page: 1));
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text('retry'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final filteredOrders = _getFilteredOrders(orders);

          return OrderListView(
            filteredOrders: filteredOrders,
            state: state,
            scrollController: _scrollController,
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          );
        },
      ),
    );
  }
}
