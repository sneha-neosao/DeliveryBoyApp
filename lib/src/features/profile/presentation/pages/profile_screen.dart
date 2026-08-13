import 'package:delivery_boy_app/src/configs/injector/injector.dart';
import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/profile/bloc/delete_account_bloc/delete_account_bloc.dart';
import 'package:delivery_boy_app/src/features/profile/presentation/widgets/change_password_input_widget.dart';
import 'package:delivery_boy_app/src/features/profile/presentation/widgets/edit_profile_input_widget.dart';
import 'package:delivery_boy_app/src/features/profile/presentation/widgets/profile_image_widget.dart';
import 'package:delivery_boy_app/src/features/widgets/app_alert_dialogue_widget.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late String name = '';
  late String phone = '';
  String? profileImageUrl; // current profile image URL

  late final ProfileBloc _profileBloc;

  void _passwordUpdate(BuildContext context) {
    primaryFocus?.unfocus();
    final authForm = context.read<PasswordUpdateFormBloc>().state;

    context.read<PasswordUpdateBloc>().add(
      PasswordUpdateGetEvent(authForm.old_password.trim(), authForm.new_password.trim(), authForm.confirm_password),
    );
  }

  void _profileUpdate(BuildContext context) {
    primaryFocus?.unfocus();
    final authForm = context.read<ProfileUpdateFormBloc>().state;

    context.read<ProfileUpdateBloc>().add(
      ProfileUpdateGetEvent(authForm.name.trim(), authForm.mobile_number.trim()),
    );
  }

  @override
  void initState() {
    super.initState();

    // Load cached session data first (immediate display)
    _loadUserData();

    // Fetch fresh profile data from API
    _profileBloc = getIt<ProfileBloc>();
    _profileBloc.add(const ProfileGetEvent());
  }

  Future<void> _loadUserData() async {
    final session = await SessionManager.getUserSession();
    final deliveryBoy = session?.data?.deliveryBoy;

    if (deliveryBoy == null || !mounted) return;

    setState(() {
      name = deliveryBoy.name ?? '';
      phone = deliveryBoy.phone ?? '';
      profileImageUrl = deliveryBoy.profileImage;
    });
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

  void _handleDeleteAccount(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => BlocProvider.value(
        value: parentContext.read<DeleteAccountBloc>(),
        child: BlocConsumer<DeleteAccountBloc, DeleteAccountState>(
          listener: (context, state) async {
            if (state is DeleteAccountSuccessState) {
              Navigator.of(dialogContext).pop();
              await SessionManager.clear();
              appSnackBar(context, AppColor.bright_red, state.data.message);
              context.go(AppRoute.login.path);
            } else if (state is DeleteAccountFailureState) {
              Navigator.of(dialogContext).pop();
              appSnackBar(context, AppColor.bright_red, state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is DeleteAccountLoadingState;
            return AppAlertDialogWidget(
              title: 'Delete Account',
              subtitle: 'Are you sure you want to delete your account? This action cannot be undone.',
              confirmText: 'Delete',
              cancelText: 'Cancel',
              icon: Icons.delete_forever_rounded,
              iconBgColor: const Color(0xFFFFEBEE),
              iconColor: AppColor.bright_red,
              confirmBtnColor: AppColor.bright_red,
              isLoading: isLoading,
              onConfirm: () {
                context.read<DeleteAccountBloc>().add(const DeleteAccountGetEvent());
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
        BlocProvider(create: (_) => getIt<PasswordUpdateBloc>()),
        BlocProvider(create: (_) => getIt<PasswordUpdateFormBloc>()),
        BlocProvider(create: (_) => getIt<ProfileUpdateBloc>()),
        BlocProvider(create: (_) => getIt<ProfileUpdateFormBloc>()),
        BlocProvider(create: (_) => getIt<AuthLoginBloc>()),
        BlocProvider(create: (_) => getIt<DeleteAccountBloc>()),
        BlocProvider(create: (_) => _profileBloc),
        BlocProvider(create: (_) => getIt<ProfileImageUpdateBloc>()),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileSuccessState) {
                final profileData = state.data.data;
                if (profileData != null && mounted) {
                  setState(() {
                    name = profileData.name;
                    phone = profileData.phone;
                    profileImageUrl = profileData.profileImage; // update image URL
                  });
                }
              }
            },
            child: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF7F0),
                  gradient: RadialGradient(
                    center: Alignment.topLeft,
                    radius: 1.4,
                    colors: [
                      Color(0xFFFFE0CC),
                      Color(0xFFFFF7F0),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    SafeArea(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),

                              // Large profile photo with edit icon
                              Center(
                                child: ProfileImageWidget(
                                  imageUrl: profileImageUrl,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Profile Details Form (Editable from start)
                              Form(
                                key: _formKey,
                                child: EditProfileInputWidget(
                                  key: ValueKey('$name-$phone'),
                                  name: name,
                                  phone: phone,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Save Button
                              BlocConsumer<ProfileUpdateBloc, ProfileUpdateState>(
                                listener: (context, state) {
                                  if (state is ProfileUpdateSuccessState) {
                                    appSnackBar(context, AppColor.green, state.data.message );
                                    context.go(AppRoute.dashboard.path);
                                  } else if (state is ProfileUpdateFailureState) {
                                    appSnackBar(context, AppColor.bright_red, state.message);
                                  }
                                },
                                builder: (context, state) {
                                  final isLoading = state is ProfileUpdateLoadingState;

                                  return ElevatedButton(
                                    onPressed: isLoading ? null : () => _profileUpdate(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFA6624),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      minimumSize: const Size.fromHeight(50),
                                      elevation: 3,
                                      shadowColor:
                                      const Color(0xFFFA6624).withValues(alpha: 0.3),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ) : const Text(
                                      'SAVE',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 32),

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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Change Password',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          BlocConsumer<PasswordUpdateBloc, PasswordUpdateState>(
                                            listener: (context, state) {
                                              if (state is PasswordUpdateSuccessState) {
                                                appSnackBar(context, AppColor.green, state.data.message );
                                                context.go(AppRoute.dashboard.path);
                                              } else if (state is PasswordUpdateFailureState) {
                                                appSnackBar(context, AppColor.bright_red, state.message);
                                              }
                                            },
                                            builder: (context, state) {
                                              final isLoading = state is PasswordUpdateLoadingState;

                                              return ElevatedButton(
                                                onPressed: isLoading ? null : () => _passwordUpdate(context),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                  const Color(0xFFFA6624),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(20),
                                                  ),
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 8),
                                                  minimumSize: Size.zero,
                                                  tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                                  elevation: 0,
                                                ),
                                                child: isLoading
                                                    ? const SizedBox(
                                                  height: 22,
                                                  width: 22,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.5,
                                                  ),
                                                ) : const Text(
                                                  'Update',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      ChangePasswordInputWidget(),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Logout Button
                              ElevatedButton(
                                onPressed: () => _handleLogout(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFF2E6),
                                  foregroundColor: const Color(0xFFFA6624),
                                  elevation: 0,
                                  side: const BorderSide(
                                      color: Color(0xFFFA6624), width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.logout_rounded, size: 20),
                                    const SizedBox(width: 8),
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
                              const SizedBox(height: 24),

                              // Delete Account Button
                              ElevatedButton(
                                onPressed: () => _handleDeleteAccount(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFEBEE),
                                  foregroundColor: AppColor.bright_red,
                                  elevation: 0,
                                  side: const BorderSide(
                                      color: AppColor.bright_red, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.delete_forever_rounded, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'DELETE ACCOUNT',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
