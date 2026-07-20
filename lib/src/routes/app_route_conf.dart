import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
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
        path: AppRoute.orders.path,
        name: AppRoute.orders.name,
        pageBuilder: (context, state) => _fadePage(const OrdersScreen()),
      ),
      GoRoute(
        path: AppRoute.delivered.path,
        name: AppRoute.delivered.name,
        pageBuilder: (context, state) => _fadePage(const DeliveredScreen()),
      ),
      GoRoute(
        path: AppRoute.cancelled.path,
        name: AppRoute.cancelled.name,
        pageBuilder: (context, state) => _fadePage(const CancelledScreen()),
      ),
      GoRoute(
        path: AppRoute.rejected.path,
        name: AppRoute.rejected.name,
        pageBuilder: (context, state) => _fadePage(const RejectedScreen()),
      ),
      GoRoute(
        path: AppRoute.profile.path,
        name: AppRoute.profile.name,
        pageBuilder: (context, state) => _fadePage(const ProfileScreen()),
      ),
    ],
  );
}

/// Fade transition page helper

CustomTransitionPage _fadePage(Widget child) => CustomTransitionPage(
  transitionDuration: const Duration(
    milliseconds: 800,
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
