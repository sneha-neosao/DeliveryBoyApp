import 'package:delivery_boy_app/src/configs/injector/injector.dart';
import 'package:delivery_boy_app/src/core/extensions/string_validator_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordTextField<T> extends StatefulWidget {
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

  const ChangePasswordTextField({
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
  State<ChangePasswordTextField<T>> createState() => _ChangePasswordTextFieldState<T>();
}

class _ChangePasswordTextFieldState<T> extends State<ChangePasswordTextField<T>> {
  bool _isVisible = true;

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access bloc or provider of type T if needed
    final formBloc = context.read<T>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
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
          if (formBloc is PasswordUpdateFormBloc) {
            if (widget.label == "old_password".tr() && val!.isEmpty) {
              return 'please_enter_old_password'.tr();
            } else if (widget.label == "old_password".tr() && !formBloc.state.old_password.isPasswordValid) {
              return 'please_enter_valid_old_password'.tr();
            } else if (widget.label == "new_password".tr() && val!.isEmpty) {
              return 'please_enter_new_password'.tr();
            } else if (widget.label == "new_password".tr() && !formBloc.state.new_password.isPasswordValid) {
              return 'please_enter_valid_new_password'.tr();
            } else if (widget.label == "confirm_password".tr() && val!.isEmpty) {
              return 'please_enter_confirm_password'.tr();
            } else if (widget.label == "confirm_password".tr() && !formBloc.state.confirm_password.isPasswordValid && formBloc.state.confirm_password != formBloc.state.new_password ) {
              return 'please_enter_valid_confirm_password'.tr();
            }
          }

          return widget.validator?.call(val);
        },
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 12.0),
            child: Icon(widget.prefixIcon, color: const Color(0xFFFA6624), size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFFA6624), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
