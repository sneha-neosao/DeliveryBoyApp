import 'package:delivery_boy_app/src/features/orders/bloc/order_status_update_bloc/order_status_update_bloc.dart';
import 'dart:math' as math;
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/features/bulk_orders/bloc/current_assignment_orders_bloc/current_assignment_orders_bloc.dart';
import 'package:delivery_boy_app/src/configs/injector/injector.dart';
import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/widgets/order_listview.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/food_order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<OrderCurrentAssignmentBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<CurrentAssignmentOrdersBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<OrderListBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<OrderStatusUpdateBloc>(),
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
  String? _deliveryType;

  // Selected Filter Tab ('All', 'Active', 'Completed')
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadDeliveryType();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadDeliveryType() async {
    final session = await SessionManager.getUserSession();
    if (mounted) {
      setState(() {
        _deliveryType = session?.data?.deliveryBoy?.deliveryType;
      });
      _initialFetch();
    }
  }

  void _initialFetch() {
    if (_deliveryType?.toLowerCase() == 'food') {
      context.read<OrderListBloc>().add(const GetOrderListEvent(page: 1));
    } else {
      context.read<OrderCurrentAssignmentBloc>().add(const OrderCurrentAssignmentGetEvent());
    }
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
    return Stack(
      children: [
        Scaffold(
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
                child: Stack(
                  children: [
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
                    _buildNavigationIcon(),
                  ],
                ),
              ),
            ),
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<OrderCurrentAssignmentBloc, OrderCurrentAssignmentState>(
                listener: (context, state) {
                  if (state is OrderCurrentAssignmentSuccessState) {
                    final assignment = state.data.data;
                    if (assignment != null && assignment.orderIds.isNotEmpty) {
                      context.read<CurrentAssignmentOrdersBloc>().add(
                            CurrentAssignmentOrdersGetEvent(assignment.uuid, 1, 100),
                          );
                    }
                  }
                  if (state is OrderCurrentAssignmentFailureState) {
                    appSnackBar(context, AppColor.bright_red, state.message);
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
              BlocListener<OrderListBloc, OrderListState>(
                listener: (context, state) {
                  if (state is OrderListFailureState) {
                    appSnackBar(context, AppColor.bright_red, state.message);
                  }
                },
              ),
              BlocListener<OrderStatusUpdateBloc, OrderStatusUpdateState>(
                listener: (context, state) {
                  if (state is OrderStatusUpdateSuccessState) {
                    appSnackBar(
                      context,
                      AppColor.green,
                      state.data.message.isNotEmpty
                          ? state.data.message
                          : 'Status updated',
                    );
                    // Refresh the list
                    _initialFetch();
                  } else if (state is OrderStatusUpdateFailureState) {
                    appSnackBar(context, AppColor.bright_red, state.message);
                  }
                },
              ),
            ],
            child: _buildBody(),
          ),
        ),
        BlocBuilder<OrderStatusUpdateBloc, OrderStatusUpdateState>(
          builder: (context, state) {
            if (state is OrderStatusUpdateLoadingState) {
              return Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColor.darkOrange),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildNavigationIcon() {
    if (_deliveryType == null) return const SizedBox.shrink();

    if (_deliveryType?.toLowerCase() == 'food') {
      return BlocBuilder<OrderListBloc, OrderListState>(
        builder: (context, state) {
          final orders = state.orders ?? [];
          return _navIcon(orders);
        },
      );
    } else {
      return BlocBuilder<CurrentAssignmentOrdersBloc, CurrentAssignmentOrdersState>(
        builder: (context, state) {
          List<Order> orders = [];
          if (state is CurrentAssignmentOrdersSuccessState) {
            orders = state.data.data.map((e) => e.toOrder()).toList();
          }
          return _navIcon(orders);
        },
      );
    }
  }

  Widget _navIcon(List<Order> orders) {
    final bool anyPickedUp = orders.any((o) {
      final s = o.orderStatus.toUpperCase();
      return s == 'PICKED_UP' || s == 'ON_THE_WAY';
    });

    if (orders.isEmpty || !anyPickedUp) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: InkWell(
          onTap: () {
            context.push(AppRoute.map.path, extra: orders);
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
    );
  }

  Widget _buildBody() {
    if (_deliveryType == null) {
      return const Center(child: CircularProgressIndicator(color: AppColor.darkOrange));
    }

    if (_deliveryType?.toLowerCase() == 'food') {
      return _buildFoodOrders();
    } else {
      return _buildVegetableOrders();
    }
  }

  Widget _buildFoodOrders() {
    return BlocBuilder<OrderListBloc, OrderListState>(
      builder: (context, state) {
        if (state is OrderListLoadingState && (state.orders == null || state.orders!.isEmpty)) {
          return const Center(child: CircularProgressIndicator(color: AppColor.darkOrange));
        }

        final orders = state.orders ?? [];
        if (orders.isEmpty) {
          return RefreshIndicator(
            color: AppColor.darkOrange,
            onRefresh: () async {
              context.read<OrderListBloc>().add(const GetOrderListEvent(page: 1, isRefresh: true));
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
                    const Text(
                      "You don't have any orders yet",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.charcoal,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You will see orders here when assign like this",
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

        final filteredOrders = _getFilteredOrders(orders);
        return OrderListView(
          filteredOrders: filteredOrders,
          loadingMore: state.loadingMore,
          scrollController: _scrollController,
          selectedFilter: _selectedFilter,
          isLoadingInitial: false,
          isError: state is OrderListFailureState && orders.isEmpty,
          errorMessage: state is OrderListFailureState && orders.isEmpty ? state.message : null,
          onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
          onRetry: () => context.read<OrderListBloc>().add(const GetOrderListEvent(page: 1)),
          deliveryType: _deliveryType,
        );
      },
    );
  }

  Widget _buildVegetableOrders() {
    return BlocBuilder<OrderCurrentAssignmentBloc, OrderCurrentAssignmentState>(
      builder: (context, currentAssignmentState) {
        if (currentAssignmentState is OrderCurrentAssignmentLoadingState ||
            currentAssignmentState is OrderCurrentAssignmentInitialState) {
          return const Center(child: CircularProgressIndicator(color: AppColor.darkOrange));
        }

        final assignment = (currentAssignmentState is OrderCurrentAssignmentSuccessState)
            ? currentAssignmentState.data.data
            : null;

        if (assignment == null || assignment.orderCount == 0 || assignment.orderIds.isEmpty) {
          return RefreshIndicator(
            color: AppColor.darkOrange,
            onRefresh: () async {
              context.read<OrderCurrentAssignmentBloc>().add(const OrderCurrentAssignmentGetEvent());
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

        return BlocBuilder<CurrentAssignmentOrdersBloc, CurrentAssignmentOrdersState>(
          builder: (context, state) {
            List<Order> orders = [];
            if (state is CurrentAssignmentOrdersSuccessState) {
              orders = state.data.data.map((e) => e.toOrder()).toList();
            }

            if (state is CurrentAssignmentOrdersLoadingState && orders.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColor.darkOrange));
            }

            final filteredOrders = _getFilteredOrders(orders);
            return OrderListView(
              filteredOrders: filteredOrders,
              loadingMore: false,
              scrollController: _scrollController,
              selectedFilter: _selectedFilter,
              isLoadingInitial: false,
              isError: state is CurrentAssignmentOrdersFailureState && orders.isEmpty,
              errorMessage: state is CurrentAssignmentOrdersFailureState && orders.isEmpty ? state.message : null,
              onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
              onRetry: () {
                if (assignment != null) {
                  context.read<CurrentAssignmentOrdersBloc>().add(
                        CurrentAssignmentOrdersGetEvent(assignment.uuid, 1, 100),
                      );
                }
              },
              deliveryType: _deliveryType,
            );
          },
        );
      },
    );
  }
}
