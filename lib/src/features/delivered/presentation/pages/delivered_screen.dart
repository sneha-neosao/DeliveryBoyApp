import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';

class DeliveredScreen extends StatefulWidget {
  const DeliveredScreen({super.key});

  @override
  State<DeliveredScreen> createState() => _DeliveredScreenState();
}

class _DeliveredScreenState extends State<DeliveredScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image for Delivered Orders
          SizedBox.expand(
            child: Image.asset(
              'assets/images/no_order_delivered_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Back Button at Top Left Corner to navigate to Orders Screen
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFFA6624)),
                    onPressed: () {
                      context.go(AppRoute.orders.path);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
