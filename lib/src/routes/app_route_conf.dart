import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_boy_app/src/features/main_screen/presentation/pages/main_screen.dart';
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
            pageBuilder: (context, state) => _fadePage(const OrdersScreen()),
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
