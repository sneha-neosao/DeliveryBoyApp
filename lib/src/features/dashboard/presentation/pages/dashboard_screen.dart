import 'package:delivery_boy_app/src/configs/injector/injector.dart';
import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/services/notification_service.dart';
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/dashboard/bloc/app_update_bloc/app_update_bloc.dart';
import 'package:delivery_boy_app/src/features/dashboard/bloc/online_status_bloc/online_status_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_list_bloc/order_list_bloc.dart';
import 'package:delivery_boy_app/src/features/bulk_orders/bloc/current_assignment_orders_bloc/current_assignment_orders_bloc.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/info_card_widget.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/order_history_overview_widget.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/wallet_card_widget.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/vegetable_order_active_assignment_widget.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/food_order_active_assignment_widget.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_boy_app/src/core/api/api_url.dart';
import 'package:delivery_boy_app/src/core/services/socket_connect_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isOnline = false;
  bool _isTogglingStatus = false;
  bool _isStartingAssignment = false;
  String? _userName;
  String? _userPhone;
  String? _userImageUrl;
  String? _deliveryType;
  int? _deliveryBoyId;

  // Dashboard stats from /dashboard/ API
  num? _totalEarning;
  num? _todaysEarning;
  double? _avgRating;
  int? _deliveredCount;
  int? _pendingCount;
  int? _cancelledCount;
  int? _totalDeliveries;

  late final ProfileBloc _profileBloc;
  late final DashboardBloc _dashboardBloc;
  late final OrderCurrentAssignmentBloc _orderCurrentAssignmentBloc;
  late final CurrentAssignmentOrdersBloc _currentAssignmentOrdersBloc;
  late final FoodOrderCurrentAssignmentBloc _foodOrderCurrentAssignmentBloc;
  late final OrderListBloc _orderListBloc;
  late final OrderStartAssignmentBloc _orderStartAssignmentBloc;
  late final OrderAssignmentBloc _orderAssignmentBloc;
  late final AppUpdateBloc _appUpdateBloc;
  late FirebaseTokenUpdateBloc _firebaseTokenUpdateBloc;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    _profileBloc = getIt<ProfileBloc>();
    _profileBloc.add(ProfileGetEvent());
    _dashboardBloc = getIt<DashboardBloc>();
    _dashboardBloc.add(DashboardGetEvent());
    _orderCurrentAssignmentBloc = getIt<OrderCurrentAssignmentBloc>();
    _currentAssignmentOrdersBloc = getIt<CurrentAssignmentOrdersBloc>();
    _foodOrderCurrentAssignmentBloc = getIt<FoodOrderCurrentAssignmentBloc>();
    _orderListBloc = getIt<OrderListBloc>();
    _orderStartAssignmentBloc = getIt<OrderStartAssignmentBloc>();
    _orderAssignmentBloc = getIt<OrderAssignmentBloc>();
    _appUpdateBloc = getIt<AppUpdateBloc>();
    _appUpdateBloc.add(const AppUpdateGetEvent());
    _firebaseTokenUpdateBloc = getIt<FirebaseTokenUpdateBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendFirebaseToken();
    });
  }

  Future<void> _loadUserSession() async {
    final session = await SessionManager.getUserSession();
    final deliveryBoy = session?.data?.deliveryBoy;
    if (mounted && deliveryBoy != null) {
      setState(() {
        _userName = deliveryBoy.name;
        _userPhone = deliveryBoy.phone;
        _userImageUrl = deliveryBoy.profileImage;
        _deliveryType = deliveryBoy.deliveryType;
        _deliveryBoyId = deliveryBoy.id;
        if (deliveryBoy.isAvailable != null) {
          _isOnline = deliveryBoy.isAvailable!;
        }
      });

      if (_deliveryType?.toLowerCase() == "food") {
        _foodOrderCurrentAssignmentBloc.add(const FoodOrderCurrentAssignmentGetEvent());
        _orderListBloc.add(const GetOrderListEvent(page: 1));
      } else {
        _orderCurrentAssignmentBloc.add(const OrderCurrentAssignmentGetEvent());
      }
    }
  }

  /// Fetch and send Firebase token if changed
  Future<void> _sendFirebaseToken() async {
    final newToken = await NoficationService.getToken();
    final savedToken = await SessionManager.getFirebaseToken();

    print("New Firebase token: $newToken");
    print("Stored Firebase token: ${savedToken ?? null}");

    if (newToken == null) return;

    // if (savedToken == null || savedToken != newToken) {
      // Send to API only if different
      _firebaseTokenUpdateBloc.add(FirebaseTokenUpdateGetEvent(newToken));

      // Save only after API call is made
      await SessionManager.saveFirebaseToken(newToken);
      print("New Firebase token saved and sent to API");
    // } else {
    //   print("Firebase token unchanged. No need to call API.");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => _profileBloc),
        BlocProvider(create: (_) => _dashboardBloc),
        BlocProvider(create: (_) => _orderCurrentAssignmentBloc),
        BlocProvider(create: (_) => _currentAssignmentOrdersBloc),
        BlocProvider(create: (_) => _foodOrderCurrentAssignmentBloc),
        BlocProvider(create: (_) => _orderListBloc),
        BlocProvider(create: (_) => _orderStartAssignmentBloc),
        BlocProvider(create: (_) => _orderAssignmentBloc),
        BlocProvider(create: (_) => _appUpdateBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          // Profile API → update name, phone, online status
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) async {
              if (state is ProfileSuccessState) {
                final profileData = state.data.data;

                // Update session with fresh profile data
                final session = await SessionManager.getUserSession();
                if (session != null && profileData != null) {
                  session.data?.deliveryBoy?.name = profileData.name;
                  session.data?.deliveryBoy?.phone = profileData.phone;
                  session.data?.deliveryBoy?.email = profileData.email;
                  session.data?.deliveryBoy?.vehicleType = profileData.vehicleType;
                  session.data?.deliveryBoy?.vehicleNumber = profileData.vehicleNumber;
                  session.data?.deliveryBoy?.profileImage = profileData.profileImage;
                  session.data?.deliveryBoy?.isActive = profileData.isActive;
                  session.data?.deliveryBoy?.isAvailable = profileData.isOnline;
                  await SessionManager.saveUserSession(session);
                }

                if (mounted) {
                  setState(() {
                    _userName = profileData?.name;
                    _userPhone = profileData?.phone;
                    _userImageUrl = profileData?.profileImage;
                    if (profileData?.isOnline != null) {
                      _isOnline = profileData!.isOnline;
                    }
                  });
                }
              }

              if (state is ProfileFailureState) {
                appSnackBar(context, AppColor.bright_red, state.message);
              }
            },
          ),

          // Dashboard API → update stats, counts, earnings
          BlocListener<DashboardBloc, DashboardState>(
            listener: (context, state) {
              if (state is DashboardSuccessState) {
                final d = state.data.data;
                if (d != null && mounted) {
                  setState(() {
                    _totalEarning = d.totalEarning;
                    _todaysEarning = d.todaysEarning;
                    _avgRating = d.avgRating;
                    _deliveredCount = d.completedOrdersCount;
                    _pendingCount = d.pendingOrdersCount;
                    _cancelledCount = d.failedOrdersCount;
                    // Total deliveries = pending + delivered
                    _totalDeliveries =
                        d.completedOrdersCount + d.pendingOrdersCount;
                  });
                }
              }

              if (state is DashboardFailureState) {
                appSnackBar(context, AppColor.bright_red, state.message);
              }
            },
          ),
          BlocListener<OrderCurrentAssignmentBloc, OrderCurrentAssignmentState>(
            listener: (context, state) {
              if (state is OrderCurrentAssignmentSuccessState) {
                final assignment = state.data.data;
                if (assignment != null && assignment.uuid.isNotEmpty) {
                  _currentAssignmentOrdersBloc.add(
                    CurrentAssignmentOrdersGetEvent(assignment.uuid, 1, 10),
                  );
                }
              }
              if (state is OrderCurrentAssignmentFailureState) {
                appSnackBar(context, AppColor.bright_red, state.message);
              }
            },
          ),
          BlocListener<FoodOrderCurrentAssignmentBloc, FoodOrderCurrentAssignmentState>(
            listener: (context, state) {
              if (state is FoodOrderCurrentAssignmentFailureState) {
                appSnackBar(context, AppColor.bright_red, state.message);
              }
            },
          ),
          BlocListener<OrderStartAssignmentBloc, OrderStartAssignmentState>(
            listener: (context, state) {
              if (state is OrderStartAssignmentLoadingState) {
                setState(() => _isStartingAssignment = true);
              } else if (state is OrderStartAssignmentSuccessState) {
                setState(() => _isStartingAssignment = false);
                appSnackBar(
                  context,
                  AppColor.green,
                  state.data.message.isNotEmpty
                      ? state.data.message
                      : 'Assignment updated successfully',
                );
                
                if (_deliveryType?.toLowerCase() == "vegetable" && _deliveryBoyId != null) {
                  final updatedOrders = state.data.data?.updatedOrders ?? [];
                  if (updatedOrders.isNotEmpty) {
                    final orderIds = updatedOrders.map((o) => o.uuId).toList();
                    
                    SessionManager.getAuthToken().then((token) async {
                      if (token != null && token.isNotEmpty) {
                        final uri = Uri.parse(ApiUrl.baseUrl);
                        final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
                        final wsUrl = '$wsScheme://${uri.authority}/api/v1/ws';
                        
                        logger.i("DashboardScreen: Connecting to Socket for Vegetable at $wsUrl");
                        final socketService = getIt<TrackingSocketService>();
                        await socketService.startTracking(
                          socketUrl: wsUrl,
                          jwtToken: token,
                        );
                        
                        logger.i("DashboardScreen: Sending delivery:accepted for vegetable orders: $orderIds");
                        socketService.acceptDelivery(
                          deliveryId: _deliveryBoyId!,
                          orderIds: orderIds,
                        );
                      } else {
                        logger.w("DashboardScreen: Auth token is empty, cannot connect socket.");
                      }
                    });
                  }
                }

                // Refresh current assignment and dashboard stats
                if (_deliveryType?.toLowerCase() == "food") {
                  _foodOrderCurrentAssignmentBloc.add(const FoodOrderCurrentAssignmentGetEvent());
                  _orderListBloc.add(const GetOrderListEvent(page: 1));
                } else {
                  _orderCurrentAssignmentBloc.add(const OrderCurrentAssignmentGetEvent());
                }
                _dashboardBloc.add(DashboardGetEvent());
              } else if (state is OrderStartAssignmentFailureState) {
                setState(() => _isStartingAssignment = false);
                appSnackBar(context, AppColor.bright_red, state.message);
              }
            },
          ),
          BlocListener<OrderAssignmentBloc, OrderAssignmentState>(
            listener: (context, state) {
              if (state is OrderAssignmentLoadingState) {
                setState(() => _isStartingAssignment = true);
              } else if (state is OrderAssignmentSuccessState) {
                setState(() => _isStartingAssignment = false);
                
                // Stop any ringing notification sound
                NoficationService.cancelAll();

                appSnackBar(
                  context,
                  AppColor.green,
                  state.data.message.isNotEmpty
                      ? state.data.message
                      : 'Assignment updated successfully',
                );

                // --- Sockets for Food Delivery Type ---
                if (_deliveryType?.toLowerCase() == "food") {
                  final orderAssignment = state.data.data;
                  if (orderAssignment != null && orderAssignment.status.toUpperCase() == 'DEL_ACCEPTED') {
                    SessionManager.getAuthToken().then((token) async {
                      if (token != null && token.isNotEmpty) {
                        // final wsUrl = "https://web.neosao.co.in/?token=$token";
                        final wsUrl = "https://web.neosao.co.in?token=$token";

                        logger.i("DashboardScreen: Connecting to Socket at $wsUrl");
                        final socketService = getIt<TrackingSocketService>();
                        await socketService.startTracking(
                          socketUrl: wsUrl,
                          jwtToken: token,
                        );
                        
                        logger.i("DashboardScreen: Sending delivery:accepted for order ${orderAssignment.orderUuId}");
                        socketService.acceptDelivery(
                          deliveryId: orderAssignment.deliveryBoyId,
                          orderIds: [orderAssignment.orderUuId],
                        );
                      } else {
                        logger.w("DashboardScreen: Auth token is empty, cannot connect socket.");
                      }
                    });
                  }
                }

                // Refresh current assignment and dashboard stats
                if (_deliveryType?.toLowerCase() == "food") {
                  _foodOrderCurrentAssignmentBloc.add(const FoodOrderCurrentAssignmentGetEvent());
                  _orderListBloc.add(const GetOrderListEvent(page: 1));
                } else {
                  _orderCurrentAssignmentBloc.add(const OrderCurrentAssignmentGetEvent());
                }
                _dashboardBloc.add(DashboardGetEvent());
              } else if (state is OrderAssignmentFailureState) {
                setState(() => _isStartingAssignment = false);
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
          BlocListener<AppUpdateBloc, AppUpdateState>(
            listener: (context, state) {
              if (state is AppUpdateSuccessState) {
                // Handle app update logic here (e.g. show dialog if version is old)
                print("App Update Status: ${state.data.status}");
              }
              if (state is AppUpdateFailureState) {
                // appSnackBar(context, AppColor.bright_red, state.message);
              }
            },
          ),
        ],
        child: BlocProvider(
          create: (_) => getIt<OnlineStatusBloc>(),
          child: Builder(
            builder: (blocContext) {
              return BlocListener<OnlineStatusBloc, OnlineStatusState>(
                listener: (context, state) {
                  if (state is OnlineStatusLoadingState) {
                    setState(() => _isTogglingStatus = true);
                  } else if (state is OnlineStatusSuccessState) {
                    setState(() => _isTogglingStatus = false);
                    appSnackBar(
                      context,
                      AppColor.green,
                      state.data.message.isNotEmpty
                          ? state.data.message
                          : _isOnline
                              ? 'You are now Online'
                              : 'You are now Offline',
                    );
                  } else if (state is OnlineStatusFailureState) {
                    setState(() {
                      _isTogglingStatus = false;
                      _isOnline = !_isOnline;
                    });
                    appSnackBar(
                        context, AppColor.bright_red, state.message);
                  }
                },
                child: Scaffold(
                  backgroundColor: const Color(0xFFFFF9F5),
                  body: Stack(
                    children: [
                      RefreshIndicator(
                        color: AppColor.darkOrange,
                        onRefresh: () async {
                          _profileBloc.add(ProfileGetEvent());
                          _dashboardBloc.add(DashboardGetEvent());
                          if (_deliveryType?.toLowerCase() == "food") {
                            _foodOrderCurrentAssignmentBloc.add(const FoodOrderCurrentAssignmentGetEvent());
                            _orderListBloc.add(const GetOrderListEvent(page: 1));
                          } else {
                            _orderCurrentAssignmentBloc.add(const OrderCurrentAssignmentGetEvent());
                          }
                          // Give it a little time to show the indicator
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              BlocBuilder<ProfileBloc, ProfileState>(
                                builder: (context, profileState) {
                                  final isProfileLoading = profileState is ProfileLoadingState;
                                  return InfoCardWidget(
                                    isOnline: _isOnline,
                                    userName: _userName,
                                    userPhone: _userPhone,
                                    userImageUrl: _userImageUrl,
                                    isLoading: isProfileLoading,
                                    onOnlineToggle: (value) {
                                      setState(() => _isOnline = value);
                                      blocContext.read<OnlineStatusBloc>().add(
                                            OnlineStatusGetEvent(value),
                                          );
                                    },
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              // Wallet / Earnings Card
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20.0),
                                child: WalletCardWidget(
                                  totalEarning: _totalEarning,
                                  todaysEarning: _todaysEarning,
                                  avgRating: _avgRating,
                                  totalDeliveries: _totalDeliveries,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Order History Overview Cards
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Order History Overview',
                                      style: TextStyle(
                                        color: AppColor.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    OrderHistoryOverviewWidget(
                                      deliveredCount: _deliveredCount,
                                      pendingCount: _pendingCount,
                                      cancelledCount: _cancelledCount,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Active Assignment Banner (Vegetable/Grocery)
                              BlocBuilder<OrderCurrentAssignmentBloc, OrderCurrentAssignmentState>(
                                builder: (context, state) {
                                  if (state is OrderCurrentAssignmentLoadingState || state is OrderCurrentAssignmentInitialState) {
                                    if (_deliveryType?.toLowerCase() == "food") return const SizedBox.shrink();
                                    return _buildShimmerBanner();
                                  }

                                  if (state is OrderCurrentAssignmentSuccessState) {
                                    final assignment = state.data.data;
                                    if (assignment == null || assignment.orderCount == 0 || assignment.orderIds.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return BlocBuilder<CurrentAssignmentOrdersBloc, CurrentAssignmentOrdersState>(
                                      builder: (context, ordersState) {
                                        String paymentMode = '';
                                        if (ordersState is CurrentAssignmentOrdersSuccessState && ordersState.data.data.isNotEmpty) {
                                          paymentMode = ordersState.data.data.first.paymentMode;
                                        }
                                        return VegetableOrderActiveAssignmentWidget(
                                          orderCount: assignment.orderCount,
                                          status: assignment.status,
                                          uuid: assignment.uuid,
                                          paymentMode: paymentMode,
                                        );
                                      },
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),

                              // Active Assignment Banner (Food)
                              BlocBuilder<OrderListBloc, OrderListState>(
                                builder: (context, state) {
                                  if (_deliveryType?.toLowerCase() != "food") return const SizedBox.shrink();

                                  final orders = state.orders;
                                  if (state is OrderListLoadingState && (orders == null || orders.isEmpty)) {
                                    return _buildShimmerBanner();
                                  }

                                  if (orders != null && orders.isNotEmpty) {
                                    final activeOrders = orders.where(
                                      (o) {
                                        final s = o.orderStatus.toUpperCase();
                                        return s != 'DELIVERED' && s != 'CANCELLED' && s != 'REJECTED';
                                      },
                                    ).toList();

                                    if (activeOrders.isEmpty) return const SizedBox.shrink();

                                    final activeOrder = activeOrders.first;

                                    return FoodOrderActiveAssignmentWidget(
                                      orderCount: activeOrders.length,
                                      assignmentStatus: activeOrder.assignmentStatus,
                                      orderStatus: activeOrder.orderStatus,
                                      uuid: activeOrder.uuId,
                                      paymentMode: activeOrder.paymentMode,
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),

                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                      if (_isStartingAssignment || _isTogglingStatus)
                        Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColor.darkOrange,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
