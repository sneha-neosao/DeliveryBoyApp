import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/services/socket_connect_service.dart';
import 'package:delivery_boy_app/src/features/widgets/safe_gif_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gif_view/gif_view.dart';
import 'package:go_router/go_router.dart';
import '../../../../configs/injector/injector.dart';
import '../../../../routes/app_route_path.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final SafeGifController _gifController;
  bool _authCheckDone = false;
  bool _gifPlayDone = false;
  bool _hasNavigated = false;
  AuthLoginState? _authState;

  @override
  void initState() {
    super.initState();
    _gifController = SafeGifController(
      loop: false,
      onFinish: () {
        if (mounted) {
          setState(() {
            _gifPlayDone = true;
          });
          _navigateIfReady();
        }
      },
    );

    // Fallback timer to ensure we don't get stuck on splash screen if the GIF fails to play
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && !_gifPlayDone) {
        setState(() {
          _gifPlayDone = true;
        });
        _navigateIfReady();
      }
    });
  }

  void _navigateIfReady() {
    if (_authCheckDone && _gifPlayDone && _authState != null && !_hasNavigated) {
      _hasNavigated = true;
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );

      if (_authState is AuthCheckSignInStatusSuccessState) {
        final session = (_authState as AuthCheckSignInStatusSuccessState).data;
        final token = session.data?.accessToken;
        if (token != null && token.isNotEmpty) {
          final wsUrl = "https://web.neosao.co.in?token=$token";
          getIt<TrackingSocketService>().startTracking(
            socketUrl: wsUrl,
            jwtToken: token,
          );
        }
        debugPrint("UserData: ${session.data}");
        context.goNamed(AppRoute.dashboard.name);
      } else {
        context.goNamed(AppRoute.getStarted.name);
      }
    }
  }

  @override
  void dispose() {
    _gifController.pause();
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AuthLoginBloc>()..add(AuthCheckSignInStatusEvent()),
        ),
      ],
      child: BlocListener<AuthLoginBloc, AuthLoginState>(
        listenWhen: (_, current) =>
            current is AuthCheckSignInStatusSuccessState || current is AuthCheckSignInStatusFailureState,
        listener: (context, state) {
          if (mounted) {
            setState(() {
              _authCheckDone = true;
              _authState = state;
            });
            _navigateIfReady();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox.expand(
            child: GifView.asset(
              'assets/gif/splash.gif',
              controller: _gifController,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
