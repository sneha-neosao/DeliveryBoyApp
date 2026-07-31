import 'package:delivery_boy_app/src/configs/injector/injector.dart';
import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
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
  bool _isOnline = true;
  bool _isTogglingStatus = false;
  String? _userName;
  String? _userPhone;
  num? _commissionWallet;
  num? _totalDeliveries;
  num? _avgRating;
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    _profileBloc = getIt<ProfileBloc>();
    _profileBloc.add(ProfileGetEvent());
  }

  Future<void> _loadUserSession() async {
    final session = await SessionManager.getUserSession();
    final deliveryBoy = session?.data?.deliveryBoy;
    if (mounted && deliveryBoy != null) {
      setState(() {
        _userName = deliveryBoy.name;
        _userPhone = deliveryBoy.phone;
        if (deliveryBoy.isAvailable != null) {
          _isOnline = deliveryBoy.isAvailable!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => _profileBloc)
      ],
      child: BlocListener<ProfileBloc, ProfileState>(
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
              session.data?.deliveryBoy?.isActive = profileData.isActive;
              session.data?.deliveryBoy?.isAvailable = profileData.isOnline;
              await SessionManager.saveUserSession(session);
            }

            setState(() {
              _userName = profileData?.name;
              _userPhone = profileData?.phone;
              _commissionWallet = profileData?.commissionWallet;
              _totalDeliveries = profileData?.totalReviews;
              _avgRating = profileData?.avgRating;
              if (profileData?.isOnline != null) {
                _isOnline = profileData!.isOnline;
              }
            });
          }

          if (state is ProfileFailureState) {
            appSnackBar(
              context,
              AppColor.bright_red,
              state.message,
            );
          }
        },
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
                      context,
                      AppColor.bright_red,
                      state.message,
                    );
                  }
                },
                child: Scaffold(
                  backgroundColor: const Color(0xFFFFF9F5),
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        InfoCardWidget(
                          isOnline: _isOnline,
                          userName: _userName,
                          userPhone: _userPhone,
                          onOnlineToggle: (value) {
                            setState(() => _isOnline = value);

                            blocContext.read<OnlineStatusBloc>().add(
                              OnlineStatusGetEvent(value),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: WalletCardWidget(
                            commissionWallet: _commissionWallet,
                            totalDeliveries: _totalDeliveries,
                            avgRating: _avgRating,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Order History Overview',
                                style: TextStyle(
                                  color: AppColor.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              OrderHistoryOverviewWidget(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Padding(
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
                              border: Border.all(
                                color: AppColor.border,
                              ),
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
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: const [
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
