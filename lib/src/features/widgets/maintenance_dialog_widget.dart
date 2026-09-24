import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../configs/injector/injector_conf.dart';
import '../../core/session/session_manager.dart';
import '../../core/theme/app_color.dart';
import '../../core/theme/app_font.dart';
import '../../routes/app_route_path.dart';
import '../login/bloc/auth_login_bloc/auth_login_bloc.dart';
import 'snackbar_widget.dart';

class MaintenanceDialogWidget extends StatelessWidget {
  final String message;

  const MaintenanceDialogWidget({
    super.key,
    required this.message,
  });

  static bool _isDialogOpen = false;

  /// Shows the non-dismissible maintenance dialog.
  static Future<void> show(BuildContext context, {required String message}) async {
    if (_isDialogOpen) return;
    if (!context.mounted) return;

    _isDialogOpen = true;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MaintenanceDialogWidget(message: message),
    );
    _isDialogOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Dialogue cannot be dismissed via back gesture or hardware back button
      },
      child: BlocProvider(
        create: (_) => getIt<AuthLoginBloc>(),
        child: BlocConsumer<AuthLoginBloc, AuthLoginState>(
          listener: (context, state) async {
            if (state is AuthLogoutSuccessState) {
              _isDialogOpen = false;
              Navigator.of(context, rootNavigator: true).pop();
              await SessionManager.clear();
              if (context.mounted) {
                appSnackBar(context, const Color(0xFFFA6624), state.data.message);
                context.go(AppRoute.login.path);
              }
            } else if (state is AuthLogoutFailureState) {
              appSnackBar(context, AppColor.bright_red, state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLogoutLoadingState;

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Icon ───────────────────────────────────────────
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF2E6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.construction_rounded,
                        color: Color(0xFFFA6624),
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Title ──────────────────────────────────────────
                    Text(
                      'Under Maintenance',
                      style: AppFont.style(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0D121F),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Subtitle / API Message ─────────────────────────
                    Text(
                      message.isNotEmpty
                          ? message
                          : 'Our system is currently under maintenance. Please try again later.',
                      textAlign: TextAlign.center,
                      style: AppFont.style(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5C616E),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Buttons ────────────────────────────────────────
                    Row(
                      children: [
                        // Exit Button
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: TextButton(
                              onPressed: () {
                                SystemNavigator.pop();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFF6F6F6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Exit',
                                style: AppFont.style(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0D121F),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Logout Button
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context.read<AuthLoginBloc>().add(AuthLogoutEvent());
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFA6624),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Logout',
                                      style: AppFont.style(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
