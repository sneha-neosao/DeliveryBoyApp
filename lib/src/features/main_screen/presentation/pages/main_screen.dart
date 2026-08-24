import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
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
    _loadDeliveryTypeAndMode();
    SessionManager.autoAssignModeNotifier.addListener(_onAutoAssignModeChanged);
  }

  @override
  void dispose() {
    SessionManager.autoAssignModeNotifier.removeListener(_onAutoAssignModeChanged);
    super.dispose();
  }

  void _onAutoAssignModeChanged() {
    if (mounted) {
      setState(() {
        _autoAssignMode = SessionManager.autoAssignModeNotifier.value;
      });
    }
  }

  Future<void> _loadDeliveryTypeAndMode() async {
    final session = await SessionManager.getUserSession();
    final mode = await SessionManager.getAutoAssignMode();
    if (mounted) {
      setState(() {
        _deliveryType = session?.data?.deliveryBoy?.deliveryType;
        _autoAssignMode = mode;
      });
    }
  }

  bool get _isVegetableAutoAssign {
    final isVegetable = _deliveryType?.trim().toLowerCase() == 'vegetable';
    final normalizedMode = (_autoAssignMode ?? '').trim().toLowerCase().replaceAll('_', '-').replaceAll(' ', '-');
    return isVegetable && normalizedMode == 'auto-assign';
  }

  List<BottomNavItem> get _currentNavItems {
    return _isVegetableAutoAssign
        ? BottomNav.autoAssignVegetableNavItems
        : BottomNav.defaultNavItems;
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    if (_isVegetableAutoAssign) {
      if (location.startsWith('/dashboard_screen')) {
        return 0; // Dashboard
      }
      if (location.startsWith('/profile_screen')) {
        return 1; // Profile
      }
      return 0;
    } else {
      if (location.startsWith('/dashboard_screen')) {
        return 0; // Dashboard
      }
      if (location.startsWith('/orders_screen') ||
          location.startsWith('/delivered_screen') ||
          location.startsWith('/cancelled_screen') ||
          location.startsWith('/rejected_screen')) {
        return 1; // Orders
      }
      if (location.startsWith('/profile_screen')) {
        return 2; // Profile
      }
      return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    if (!_showBottomNav) {
      setState(() {
        _showBottomNav = true;
      });
    }
    final targetPath = _currentNavItems[index].path;
    context.go(targetPath);
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
    final selectedIndex = _calculateSelectedIndex(context);
    final navItems = _currentNavItems;

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
              selectedIndex: selectedIndex,
              items: navItems,
              onTap: (index) => _onItemTapped(index, context),
            ),
          ),
        ),
      ),
    );
  }
}
