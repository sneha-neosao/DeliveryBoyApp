import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_route_path.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final GifController _gifController;

  @override
  void initState() {
    super.initState();
    _gifController = GifController(
      loop: false,
      onFinish: () {
        if (mounted) {
          context.go(AppRoute.getStarted.path);
        }
      },
    );
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: GifView.asset(
          'assets/gif/splash.gif',
          controller: _gifController,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
