import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/info_card_widget.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/order_history_overview_widget.dart';
import 'package:delivery_boy_app/src/features/dashboard/presentation/widgets/wallet_card_widget.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isOnline = true;
  String? _userName;
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5), // soft cream background
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Gradient Header with Profile & Online Toggle
            InfoCardWidget(
              isOnline: _isOnline,
              userName: _userName,
              userPhone: _userPhone,
              onOnlineToggle: (value) {
                setState(() {
                  _isOnline = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // Wallet & Earnings Card
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: WalletCardWidget(),
            ),

            const SizedBox(height: 20),

            // Quick Navigation Shortcuts (Delivered, Cancelled, Rejected)
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

            // Active Orders Quick Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF2E6), Color(0xFFFFE8D6)],
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
                      onTap: () => context.go(AppRoute.orders.path),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.darkOrange,
                          borderRadius: BorderRadius.circular(16),
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

            const SizedBox(height: 100), // padding for bottom nav clearance
          ],
        ),
      ),
    );
  }
}
