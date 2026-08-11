import 'package:delivery_boy_app/src/configs/injector/injector.dart';
import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/order_listview.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/food_order_model/order_list_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<OrderCurrentAssignmentBloc>()..add(const OrderCurrentAssignmentGetEvent()),
        ),
        BlocProvider(
          create: (_) => getIt<OrderListBloc>(),
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final bloc = context.read<OrderListBloc>();
      final state = bloc.state;
      if (!state.loadingMore &&
          !state.hasReachedMax &&
          state is! OrderListLoadingState) {
        bloc.add(GetOrderListEvent(page: state.currentPage + 1));
      }
    }
  }

  List<Order> _getFilteredOrders(List<Order> allOrders) {
    if (_selectedFilter == 'Active') {
      return allOrders.where((o) {
        final status = o.orderStatus.toLowerCase();
        final assignStatus = o.assignmentStatus.toLowerCase();
        return status == 'assigned' ||
            status == 'active' ||
            assignStatus == 'assigned' ||
            o.isAssigned;
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
      appBar: PreferredSize(
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
            child: Center(
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
          ),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<OrderCurrentAssignmentBloc, OrderCurrentAssignmentState>(
            listener: (context, currentAssignmentState) {
              if (currentAssignmentState is OrderCurrentAssignmentSuccessState) {
                final assignment = currentAssignmentState.data.data;
                if (assignment != null &&
                    assignment.orderIds.isNotEmpty &&
                    context.read<OrderListBloc>().state is OrderListInitialState) {
                  context.read<OrderListBloc>().add(const GetOrderListEvent(page: 1));
                }
              }
            },
          ),
          BlocListener<OrderListBloc, OrderListState>(
            listener: (context, state) {
              if (state is OrderListFailureState) {
                appSnackBar(context, AppColor.bright_red, state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<OrderCurrentAssignmentBloc, OrderCurrentAssignmentState>(
          builder: (context, currentAssignmentState) {
            if (currentAssignmentState is OrderCurrentAssignmentLoadingState ||
                currentAssignmentState is OrderCurrentAssignmentInitialState) {
              return const Center(
                child: CircularProgressIndicator(color: AppColor.darkOrange),
              );
            }

            final assignment = (currentAssignmentState is OrderCurrentAssignmentSuccessState)
                ? currentAssignmentState.data.data
                : null;

            if (assignment == null || assignment.orderCount == 0 || assignment.orderIds.isEmpty) {
              return RefreshIndicator(
                color: AppColor.darkOrange,
                onRefresh: () async {
                  context.read<OrderCurrentAssignmentBloc>().add(
                        const OrderCurrentAssignmentGetEvent(),
                      );
                  context.read<OrderListBloc>().add(
                      const GetOrderListEvent(page: 1, isRefresh: true));
                  await Future.delayed(const Duration(seconds: 1));
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
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: AppColor.darkOrange,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'no_orders_yet'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.charcoal,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'home_no_orders_subtitle'.tr(),
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

            return BlocBuilder<OrderListBloc, OrderListState>(
              builder: (context, state) {
                final orders = state.orders ?? [];
                final isLoadingInitial =
                    state is OrderListLoadingState && orders.isEmpty;
                final isError = state is OrderListFailureState && orders.isEmpty;

                final filteredOrders = _getFilteredOrders(orders);

                return OrderListView(
                  filteredOrders: filteredOrders,
                  state: state,
                  scrollController: _scrollController,
                  selectedFilter: _selectedFilter,
                  isLoadingInitial: isLoadingInitial,
                  isError: isError,
                  errorMessage: state is OrderListFailureState && orders.isEmpty
                      ? state.message
                      : null,
                  onFilterChanged: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  onRetry: () {
                    context.read<OrderListBloc>().add(const GetOrderListEvent(page: 1));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
