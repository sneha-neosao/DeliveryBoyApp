import 'package:delivery_boy_app/src/features/map/presentation/pages/map_screen.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/food_order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/vegetable_grocery_order_models/order_current_assignment_reponse.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_boy_app/src/features/main_screen/presentation/pages/main_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'app_route_path.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> globalNavigator = GlobalKey<NavigatorState>();

class AppRouteConf {
  GoRouter get router => _router;

  late final _router = GoRouter(
    navigatorKey: globalNavigator,
    initialLocation: AppRoute.splash.path,
    debugLogDiagnostics: true,

    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        pageBuilder: (context, state) => _fadePage(const SplashScreen()),
      ),
      GoRoute(
        path: AppRoute.getStarted.path,
        name: AppRoute.getStarted.name,
        pageBuilder: (context, state) => _fadePage(const GetStartedScreen()),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        pageBuilder: (context, state) => _fadePage(const LoginScreen()),
      ),
      GoRoute(
        path: AppRoute.orderDetails.path,
        name: AppRoute.orderDetails.name,
        pageBuilder: (context, state) {
          if (state.extra is Order) {
            return _fadePage(OrderDetailsScreen(order: state.extra as Order));
          } else if (state.extra is String) {
            return _fadePage(OrderDetailsScreen(orderUuid: state.extra as String));
          } else if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            return _fadePage(
              OrderDetailsScreen(
                order: map['order'] as Order?,
                orderUuid: map['orderUuid'] as String?,
                fetchAssignmentFirst: map['fetchAssignmentFirst'] as bool? ?? false,
                deliveryType: map['deliveryType'] as String?,
              ),
            );
          }
          final order = state.extra as Order?;
          return _fadePage(OrderDetailsScreen(order: order));
        },
      ),
      GoRoute(
        path: AppRoute.bulkOrderDetails.path,
        name: AppRoute.bulkOrderDetails.name,
        pageBuilder: (context, state) {
          if (state.extra is Order) {
            return _fadePage(BulkOrderDetailsScreen(order: state.extra as Order));
          } else if (state.extra is String) {
            return _fadePage(BulkOrderDetailsScreen(assignmentUuid: state.extra as String));
          } else if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            return _fadePage(
              BulkOrderDetailsScreen(
                order: map['order'] as Order?,
                orderUuid: map['orderUuid'] as String?,
                assignmentUuid: map['assignmentUuid'] as String?,
              ),
            );
          }
          final order = state.extra as Order?;
          return _fadePage(BulkOrderDetailsScreen(order: order));
        },
      ),

      GoRoute(
        path: AppRoute.bulkOrder.path,
        name: AppRoute.bulkOrder.name,
        pageBuilder: (context, state) {
          final assignment = state.extra as AssignmentBatch?;
          return _fadePage(BulkOrderScreen(assignment: assignment));
        },
      ),
      GoRoute(
        path: AppRoute.map.path,
        name: AppRoute.map.name,
        pageBuilder: (context, state) {
          final orders = state.extra as List<Order>?;
          return _fadePage(MapScreen(orders: orders ?? []));
        },
      ),
      GoRoute(
        path: AppRoute.orderMap.path,
        name: AppRoute.orderMap.name,
        pageBuilder: (context, state) {
          final orders = state.extra as List<Order>?;
          return _fadePage(OrderMapScreen(orders: orders ?? []));
        },
      ),

      GoRoute(
        path: AppRoute.bulkOrderMap.path,
        name: AppRoute.bulkOrderMap.name,
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          final storeLocation = data['storeLocation'] as LatLng;
          final deliveryLocations = data['deliveryLocations'] as List<LatLng>;
          final orders = (data['orders'] as List<Order>?) ?? [];

          return _fadePage(
            BulkOrderMapScreen(
              storeLocation: storeLocation,
              deliveryLocations: deliveryLocations,
              orders: orders,
            ),
          );
        },
      ),

      // Shell route for bottom navigation bar screens
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoute.dashboard.path,
            name: AppRoute.dashboard.name,
            pageBuilder: (context, state) => _fadePage(const DashboardScreen()),
          ),
          GoRoute(
            path: AppRoute.orders.path,
            name: AppRoute.orders.name,
            pageBuilder: (context, state) => _fadePage(const OrdersTabWrapper()),
          ),
          GoRoute(
            path: AppRoute.history.path,
            name: AppRoute.history.name,
            pageBuilder: (context, state) => _fadePage(const HistoryScreen()),
          ),
          GoRoute(
            path: AppRoute.profile.path,
            name: AppRoute.profile.name,
            pageBuilder: (context, state) => _fadePage(const ProfileScreen()),
          ),
        ],
      ),
    ],
  );
}

/// Fade transition page helper

CustomTransitionPage _fadePage(Widget child) => CustomTransitionPage(
  transitionDuration: const Duration(
    milliseconds: 500,
  ), // Duration of the animation
  child: child,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut, // Smooth in-out fade
    );

    return FadeTransition(opacity: curvedAnimation, child: child);
  },
);
