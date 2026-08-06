import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/features/bulk_orders/presentation/pages/bulk_order_screen.dart';
import 'package:delivery_boy_app/src/features/orders/presentation/pages/orders_screen.dart';
import 'package:flutter/material.dart';

class OrdersTabWrapper extends StatefulWidget {
  const OrdersTabWrapper({super.key});

  @override
  State<OrdersTabWrapper> createState() => _OrdersTabWrapperState();
}

class _OrdersTabWrapperState extends State<OrdersTabWrapper> {
  String? _deliveryType;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDeliveryType();
  }

  Future<void> _loadDeliveryType() async {
    final session = await SessionManager.getUserSession();
    if (mounted) {
      setState(() {
        _deliveryType = session?.data?.deliveryBoy?.deliveryType;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColor.darkOrange),
        ),
      );
    }

    if (_deliveryType?.toLowerCase() == 'vegetable') {
      return const BulkOrderScreen(isFromTab: true);
    }

    return const OrdersScreen();
  }
}
