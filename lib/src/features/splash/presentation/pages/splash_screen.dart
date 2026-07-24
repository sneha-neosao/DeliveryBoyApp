import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
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
  late final GifController _gifController;

  @override
  void initState() {
    super.initState();
    _gifController = GifController(
      loop: false,
    );
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
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (!context.mounted) return;

            SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.edgeToEdge,
              overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
            );

            if (state is AuthCheckSignInStatusSuccessState) {
              debugPrint("UserData: ${state.data}");
              context.goNamed(AppRoute.dashboard.name);
            } else {
              context.goNamed(AppRoute.getStarted.name);
            }
          });
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
