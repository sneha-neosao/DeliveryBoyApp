import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/login/presentation/widgets/login_input_widget.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../configs/injector/injector.dart';
import '../../../../routes/app_route_path.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  void _login(BuildContext context) {
    primaryFocus?.unfocus();
    final authForm = context.read<AuthLoginFormBloc>().state;

    context.read<AuthLoginBloc>().add(
      AuthLoginEvent(authForm.email.trim(), authForm.password.trim(),),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AuthLoginFormBloc>(),
        ),
        BlocProvider(
            create: (_) => getIt<AuthLoginBloc>()
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            // Full Screen Background Image
            SizedBox.expand(
              child: Image.asset(
                'assets/images/login_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            // Inputs Overlay
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.48), // Spacing to start forms below the upper graphic portion
                    Text(
                      'login_title'.tr(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColor.charcoal, // Dark Charcoal
                      ),
                    ),
                    6.hS,
                    Text(
                      'login_subtitle'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColor.slateGrey, // Slate Grey
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    20.hS,

                    // Inputs (Mobile/Email & Password)
                    LoginInputWidget(),
                    6.hS,

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Action
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'login_forgot_password'.tr(),
                          style: const TextStyle(
                            color: AppColor.darkOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    20.hS,

                    // Login Action Button with BlocConsumer
                    BlocConsumer<AuthLoginBloc, AuthLoginState>(
                      listener: (context, state) {
                        if (state is AuthLoginSuccessState) {
                          appSnackBar(context, AppColor.green, state.data.message ?? "Login successfully");
                          context.go(AppRoute.dashboard.path);
                        } else if (state is AuthLoginFailureState) {
                          appSnackBar(context, AppColor.bright_red, state.message);
                        }
                      },
                      builder: (context, state) {
                        final isLoading = state is AuthLoginLoadingState;

                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.darkOrange,
                              foregroundColor: AppColor.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 3,
                              shadowColor: AppColor.darkOrange.withValues(alpha: 0.4),
                            ),
                            onPressed: isLoading ? null : () => _login(context),
                            child: isLoading
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'login_button'.tr(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                8.hS,
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    40.hS,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
