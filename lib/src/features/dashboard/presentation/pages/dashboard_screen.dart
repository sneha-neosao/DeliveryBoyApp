import 'package:delivery_boy_app/src/configs/injector/injector.dart';
import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/services/notification_service.dart';
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/dashboard/bloc/online_status_bloc/online_status_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_list_bloc/order_list_bloc.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/info_card_widget.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/order_history_overview_widget.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/wallet_card_widget.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
  late final FoodOrderCurrentAssignmentBloc _foodOrderCurrentAssignmentBloc;
  late final OrderListBloc _orderListBloc;
  late final OrderStartAssignmentBloc _orderStartAssignmentBloc;
  late final OrderAssignmentBloc _orderAssignmentBloc;
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
    _foodOrderCurrentAssignmentBloc = getIt<FoodOrderCurrentAssignmentBloc>();
    _orderListBloc = getIt<OrderListBloc>();
    _orderStartAssignmentBloc = getIt<OrderStartAssignmentBloc>();
    _orderAssignmentBloc = getIt<OrderAssignmentBloc>();
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
        BlocProvider(create: (_) => _foodOrderCurrentAssignmentBloc),
        BlocProvider(create: (_) => _orderListBloc),
        BlocProvider(create: (_) => _orderStartAssignmentBloc),
        BlocProvider(create: (_) => _orderAssignmentBloc),
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
                
                final updatedOrders = state.data.data?.updatedOrders ?? [];
                final isPickedUp = updatedOrders.any((o) => o.toStatus.toUpperCase() == 'PICKED_UP');
                if (isPickedUp && updatedOrders.isNotEmpty) {
                  final firstOrderId = updatedOrders.first.uuId.toString();
                  
                  SessionManager.getAuthToken().then((token) {
                    if (token != null && token.isNotEmpty) {
                      final uri = Uri.parse(ApiUrl.baseUrl);
                      final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
                      final wsUrl = '$wsScheme://${uri.authority}/api/v1/ws?token=$token';
                      
                      logger.i("DashboardScreen: Connecting to Socket at $wsUrl");
                      getIt<TrackingSocketService>().startTracking(
                        socketUrl: wsUrl,
                        orderId: firstOrderId,
                      );
                    } else {
                      logger.w("DashboardScreen: Auth token is empty, cannot connect socket.");
                    }
                  });
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
                                    return _buildActiveAssignmentBanner(
                                      context: context,
                                      orderCount: assignment.orderCount,
                                      status: assignment.status,
                                      uuid: assignment.uuid,
                                      isFood: false,
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

                                    return _buildActiveAssignmentBanner(
                                      context: context,
                                      orderCount: activeOrders.length,
                                      status: activeOrder.assignmentStatus,
                                      orderStatus: activeOrder.orderStatus,
                                      uuid: activeOrder.uuId,
                                      isFood: true,
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

  Widget _buildActiveAssignmentBanner({
    required BuildContext context,
    required int orderCount,
    required String status,
    String? orderStatus,
    required String uuid,
    bool isFood = false,
  }) {
    final assignmentStatus = status.toUpperCase();
    final oStatus = (orderStatus ?? "").toUpperCase();

    final bool showStart =
        assignmentStatus == 'PREPAIRING' || assignmentStatus == 'PREPARING';
    final bool showInactivePickedUp = assignmentStatus == 'DEL_ACCEPTED';
    final bool showActivePickedUp =
        assignmentStatus == 'READY_FOR_PICKUP' ||
            oStatus == 'READY_FOR_PICKUP';

    // For food orders, we show RELEASE and ACCEPT buttons
    // Show if either assignment status or order status indicates it's pending/assigned
    final bool showFoodActions = isFood &&
        (assignmentStatus == 'PENDING' ||
            assignmentStatus == 'ASSIGNED' ||
            assignmentStatus == 'ASSIGN' ||
            assignmentStatus == 'PLACED' ||
            assignmentStatus == 'ACCEPTED' ||
            assignmentStatus == 'ACTIVE' ||
            assignmentStatus == 'PREPARING' ||
            assignmentStatus == '' ||
            oStatus == 'PENDING' ||
            oStatus == 'PLACED' ||
            oStatus == 'ACCEPTED' ||
            oStatus == 'ASSIGNED' ||
            oStatus == 'PREPARING' ||
            oStatus == 'ACTIVE' ||
            oStatus == '');

    final bool showButton = showStart ||
        showInactivePickedUp ||
        showActivePickedUp ||
        showFoodActions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFF2E6),
              Color(0xFFFFE8D6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.shopping_bag_rounded,
              color: AppColor.darkOrange,
              size: 32,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Assignment ($orderCount)',
                    style: const TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showButton) ...[
                    const SizedBox(height: 6),
                    if (showFoodActions)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton(
                            onPressed: () => _showReleaseDialog(context, uuid),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColor.bright_red,
                              side: const BorderSide(
                                color: AppColor.bright_red,
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'RELEASE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              context.read<OrderAssignmentBloc>().add(
                                    OrderAssignmentGetEvent(
                                      uuid,
                                      'DEL_ACCEPTED',
                                      null,
                                    ),
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.darkOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'ACCEPT',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 14),
                              ],
                            ),
                          ),
                        ],
                      )
                    else if (showStart)
                      InkWell(
                        onTap: () {
                          context.read<OrderStartAssignmentBloc>().add(
                                OrderStartAssignmentGetEvent(
                                  uuid,
                                  'DEL_ACCEPTED',
                                ),
                              );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.darkOrange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'START',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (showInactivePickedUp)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_bag_rounded,
                              color: Colors.grey.shade500,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PICKED UP',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (showActivePickedUp)
                      InkWell(
                        onTap: () {
                          context.read<OrderStartAssignmentBloc>().add(
                                OrderStartAssignmentGetEvent(
                                  uuid,
                                  'PICKED_UP',
                                ),
                              );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.darkOrange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_bag_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'PICKED UP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            // navigation icon button in circle with orange border and white color bg and navigation icon in orange colro
            InkWell(
              onTap: () {
                context.go(AppRoute.orders.path);
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
                child: const Icon(
                  Icons.info_rounded,
                  color: AppColor.darkOrange,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReleaseDialog(BuildContext context, String uuid) {
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
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        const SizedBox(width: 12),
                        const Text(
                          'Release Order',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reasonCtrl,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Enter release reason',
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
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter reason';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
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
                                    uuid,
                                    'REJECTED',
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
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SUBMIT',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) => _reasonCtrl.dispose());
  }
}
