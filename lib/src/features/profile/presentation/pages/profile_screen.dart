import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/features/login/bloc/auth_login_bloc/auth_login_bloc.dart';
import 'package:delivery_boy_app/src/features/profile/presentation/widgets/change_password_input_widget.dart';
import 'package:delivery_boy_app/src/features/profile/presentation/widgets/edit_profile_input_widget.dart';
import 'package:delivery_boy_app/src/features/widgets/app_alert_dialogue_widget.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;

  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'neosao');
    _phoneController = TextEditingController(text: '8482940592');
    _emailController = TextEditingController(text: 'neosao@gmail.com');
    _locationController = TextEditingController(text: 'Kolhapur');

    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleProfileSave() {
    if (_formKey.currentState?.validate() ?? false) {
      appSnackBar(context, const Color(0xFFFA6624), 'Profile details saved successfully!');
    }
  }

  void _handlePasswordUpdate() {
    if (_passwordFormKey.currentState?.validate() ?? false) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        appSnackBar(context, Colors.redAccent, 'New password and confirm password do not match!');
        return;
      }
      
      appSnackBar(context, const Color(0xFFFA6624), 'Password updated successfully!');
      
      // Clear password inputs on successful update
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  void _handleLogout(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => BlocProvider.value(
        value: parentContext.read<AuthLoginBloc>(),
        child: BlocConsumer<AuthLoginBloc, AuthLoginState>(
          listener: (context, state) async {
            if (state is AuthLogoutSuccessState) {
              Navigator.of(dialogContext).pop();
              await SessionManager.clear();
              appSnackBar(context, const Color(0xFFFA6624), state.data.message);
              context.go(AppRoute.login.path);
            } else if (state is AuthLogoutFailureState) {
              Navigator.of(dialogContext).pop();
              appSnackBar(context, Colors.redAccent, state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLogoutLoadingState;
            return AppAlertDialogWidget(
              title: 'Logout',
              subtitle: 'Are you sure you want to logout from your account?',
              confirmText: 'Logout',
              cancelText: 'Cancel',
              icon: Icons.logout_rounded,
              iconBgColor: const Color(0xFFFFF2E6),
              iconColor: const Color(0xFFFA6624),
              confirmBtnColor: const Color(0xFFFA6624),
              isLoading: isLoading,
              onConfirm: () {
                context.read<AuthLoginBloc>().add(AuthLogoutEvent());
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AuthLoginBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7F0), // cream
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.4,
            colors: [
              Color(0xFFFFE0CC), // soft glowing light-orange tint
              Color(0xFFFFF7F0), // cream
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      20.hS, // top spacing

                      // Large profile photo with thick orange border and shadow
                      Center(
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFEAD9),
                            border: Border.all(color: const Color(0xFFFA6624), width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFA6624).withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_pin_rounded,
                            size: 60,
                            color: Color(0xFFFA6624),
                          ),
                        ),
                      ),
                      32.hS,

                      // Profile Details Form (Editable from start)
                      Form(
                        key: _formKey,
                        child: EditProfileInputWidget(
                          nameController: _nameController,
                          phoneController: _phoneController,
                          emailController: _emailController,
                          locationController: _locationController,
                        ),
                      ),
                      24.hS,

                      // Save Button
                      ElevatedButton(
                        onPressed: _handleProfileSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFA6624),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size.fromHeight(50),
                          elevation: 3,
                          shadowColor: const Color(0xFFFA6624).withValues(alpha: 0.3),
                        ),
                        child: const Text(
                          'SAVE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      32.hS,

                      // Change Password Section Container
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _passwordFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Change Password',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _handlePasswordUpdate,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFA6624),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Update',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              20.hS,
                              ChangePasswordInputWidget(
                                oldPasswordController: _oldPasswordController,
                                newPasswordController: _newPasswordController,
                                confirmPasswordController: _confirmPasswordController,
                              ),
                            ],
                          ),
                        ),
                      ),
                      24.hS,

                      // Logout Button (Matching theme)
                      ElevatedButton(
                        onPressed: () => _handleLogout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF2E6),
                          foregroundColor: const Color(0xFFFA6624),
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFFFA6624), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded, size: 20),
                            8.wS,
                            const Text(
                              'LOGOUT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      24.hS,
                    ],
                  ),
                ),
              ),
            ),

            // Back Button at Top Left Corner to navigate to Orders Screen
            // SafeArea(
            //   child: Align(
            //     alignment: Alignment.topLeft,
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            //       child: Container(
            //         decoration: BoxDecoration(
            //           color: AppColor.white.withValues(alpha: 0.9),
            //           shape: BoxShape.circle,
            //           boxShadow: [
            //             BoxShadow(
            //               color: AppColor.black.withValues(alpha: 0.05),
            //               blurRadius: 6,
            //               offset: const Offset(0, 3),
            //             ),
            //           ],
            //         ),
            //         child: IconButton(
            //           icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFFA6624)),
            //           onPressed: () {
            //             context.go(AppRoute.orders.path);
            //           },
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  },
  ),
);
  }
}
