import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      appBar: AppBar(
        title: Text(
          'drawer_order_history'.tr().isNotEmpty
              ? 'drawer_order_history'.tr()
              : 'Order History',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColor.darkOrange,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'Order History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.charcoal,
          ),
        ),
      ),
    );
  }
}
