import 'package:delivery_boy_app/src/features/profile/presentation/widgets/change_password_textfield.dart';
import 'package:flutter/material.dart';

class ChangePasswordInputWidget extends StatelessWidget {
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;

  const ChangePasswordInputWidget({
    super.key,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChangePasswordTextField(
          controller: oldPasswordController,
          prefixIcon: Icons.vpn_key_rounded,
          hintText: 'Old Password',
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter old password';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        ChangePasswordTextField(
          controller: newPasswordController,
          prefixIcon: Icons.vpn_key_rounded,
          hintText: 'New Password',
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter new password';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        ChangePasswordTextField(
          controller: confirmPasswordController,
          prefixIcon: Icons.vpn_key_rounded,
          hintText: 'Confirm Password',
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm new password';
            }
            return null;
          },
        ),
      ],
    );
  }
}
