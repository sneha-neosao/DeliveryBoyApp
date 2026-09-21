import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_boy_app/src/features/main_screen/presentation/widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _showBottomNav = true;
  int _lastSelectedIndex = -1;
  String? _deliveryType;
  String? _autoAssignMode;

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
    SessionManager.deliveryTypeNotifier.addListener(_onDeliveryInfoChanged);
    SessionManager.autoAssignModeNotifier.addListener(_onDeliveryInfoChanged);
  }

  @override
  void dispose() {
    SessionManager.deliveryTypeNotifier.removeListener(_onDeliveryInfoChanged);
    SessionManager.autoAssignModeNotifier.removeListener(_onDeliveryInfoChanged);
    super.dispose();
  }

  Future<void> _loadSessionInfo() async {
    final session = await SessionManager.getUserSession();
    final mode = await SessionManager.getAutoAssignMode();
    if (mounted) {
      setState(() {
        _deliveryType = session?.data?.deliveryBoy?.deliveryType;
        _autoAssignMode = mode;
      });
    }
  }

  void _onDeliveryInfoChanged() {
    if (mounted) {
      setState(() {
        _deliveryType = SessionManager.deliveryTypeNotifier.value ?? _deliveryType;
        _autoAssignMode = SessionManager.autoAssignModeNotifier.value ?? _autoAssignMode;
      });
    }
  }

  List<BottomNavItem> _getActiveNavItems() {
    final bool isFood = _deliveryType?.toLowerCase() == 'food';
    final normalizedMode = (_autoAssignMode ?? '').trim().toLowerCase().replaceAll('_', '-');
    final bool isAutoAssign = normalizedMode == 'auto-assign';

    // In case of food, hide orders tab.
    // In case of vegetable auto-assign, hide orders tab.
    // In case of vegetable slot-wise, orders tab is visible.
    final bool showOrders = !isFood && !isAutoAssign;

    if (showOrders) {
      return const [
        BottomNav.dashboardItem,
        BottomNav.ordersItem,
        BottomNav.historyItem,
        BottomNav.profileItem,
      ];
    } else {
      return const [
        BottomNav.dashboardItem,
        BottomNav.historyItem,
        BottomNav.profileItem,
      ];
    }
  }

  int _calculateSelectedIndex(BuildContext context, List<BottomNavItem> navItems) {
    final String location = GoRouterState.of(context).uri.path;
    for (int i = 0; i < navItems.length; i++) {
      if (location.startsWith(navItems[i].path)) {
        return i;
      }
    }
    if (location.startsWith('/delivered_screen') ||
        location.startsWith('/cancelled_screen') ||
        location.startsWith('/rejected_screen')) {
      final historyIdx = navItems.indexWhere((item) => item.path == '/history_screen');
      if (historyIdx != -1) return historyIdx;
      final ordersIdx = navItems.indexWhere((item) => item.path == '/orders_screen');
      if (ordersIdx != -1) return ordersIdx;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, List<BottomNavItem> navItems) {
    if (!_showBottomNav) {
      setState(() {
        _showBottomNav = true;
      });
    }
    if (index >= 0 && index < navItems.length) {
      final targetPath = navItems[index].path;
      context.go(targetPath);
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical) {
      if (notification is ScrollUpdateNotification) {
        final double delta = notification.scrollDelta ?? 0.0;

        if (delta > 0.5) {
          // Immediately glide hide on scroll DOWN
          if (_showBottomNav) {
            setState(() {
              _showBottomNav = false;
            });
          }
        } else if (delta < -0.5) {
          // Immediately glide show on scroll UP
          if (!_showBottomNav) {
            setState(() {
              _showBottomNav = true;
            });
          }
        }
      }

      // Always ensure visible at top
      if (notification.metrics.pixels <= 10) {
        if (!_showBottomNav) {
          setState(() {
            _showBottomNav = true;
          });
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _getActiveNavItems();
    final selectedIndex = _calculateSelectedIndex(context, navItems);

    if (_lastSelectedIndex != -1 && _lastSelectedIndex != selectedIndex) {
      _showBottomNav = true;
    }
    _lastSelectedIndex = selectedIndex;

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (selectedIndex != 0) {
          if (!_showBottomNav) {
            setState(() {
              _showBottomNav = true;
            });
          }
          context.go(navItems[0].path);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: widget.child,
        ),
        bottomNavigationBar: AnimatedSlide(
          offset: _showBottomNav ? Offset.zero : const Offset(0, 1.4),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: IgnorePointer(
            ignoring: !_showBottomNav,
            child: BottomNav(
              items: navItems,
              selectedIndex: selectedIndex,
              onTap: (index) => _onItemTapped(index, context, navItems),
            ),
          ),
        ),
      ),
    );
  }
}
