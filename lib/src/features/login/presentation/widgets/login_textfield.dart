import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/extensions/string_validator_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/login/bloc/auth_login_form/auth_login_form_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginTextField<T> extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController? controller;
  final bool isSecure;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final String? initialValue;
  final bool? readOnly;
  final TextCapitalization? textCapitalization;

  const LoginTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.controller,
    this.isSecure = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.initialValue,
    this.readOnly,
    this.textCapitalization,
  });

  @override
  State<LoginTextField<T>> createState() => _LoginTextFieldState<T>();
}

class _LoginTextFieldState<T> extends State<LoginTextField<T>> {
  bool _isVisible = true;

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formBloc = context.read<T>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColor.charcoal,
          ),
        ),
        4.hS,
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: widget.isSecure ? _isVisible : false,
          onChanged: widget.onChanged,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
          inputFormatters: widget.inputFormatters,
          keyboardType: widget.keyboardType,
          readOnly: widget.readOnly ?? false,
          validator: (val) {
            if (formBloc is AuthLoginFormBloc) {
              if (widget.label == "email".tr() && val!.isEmpty) {
                return "please_enter_email".tr();
              } else if (widget.label == "email".tr() && !formBloc.state.email.isEmailValid) {
                return "please_enter_valid_email".tr();
              } else if (widget.label == "login_password_label".tr() && val!.isEmpty) {
                return "please_enter_password".tr();
              } else if (widget.label == "login_password_label".tr() && !formBloc.state.password.isPasswordValid) {
                return "please_enter_valid_password".tr();
              }
            }

            return widget.validator?.call(val);
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(widget.prefixIcon, color: AppColor.icon),
            suffixIcon: widget.isSecure
                ? IconButton(
                    onPressed: _toggleVisibility,
                    icon: Icon(
                      _isVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF7A869A),
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColor.white.withValues(alpha: 0.9),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            errorStyle: const TextStyle(
              fontSize: 11,
              color: AppColor.bright_red,
              height: 1.2,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
