import 'package:delivery_boy_app/src/configs/injector/injector.dart';
import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/services/notification_service.dart';
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/dashboard/bloc/online_status_bloc/online_status_bloc.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/info_card_widget.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/order_history_overview_widget.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/wallet_card_widget.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
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
  String? _userName;
  String? _userPhone;
  String? _userImageUrl;

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
  late FirebaseTokenUpdateBloc _firebaseTokenUpdateBloc;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    _profileBloc = getIt<ProfileBloc>();
    _profileBloc.add(ProfileGetEvent());
    _dashboardBloc = getIt<DashboardBloc>();
    _dashboardBloc.add(DashboardGetEvent());
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
        if (deliveryBoy.isAvailable != null) {
          _isOnline = deliveryBoy.isAvailable!;
        }
      });
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
                  body: SingleChildScrollView(
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

                        // Active Assignment Banner
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20.0),
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
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Active Assignment',
                                        style: TextStyle(
                                          color: AppColor.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Check active assigned orders and delivery details',
                                        style: TextStyle(
                                          color: AppColor.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () =>
                                      context.go(AppRoute.orders.path),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.darkOrange,
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      'View',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
