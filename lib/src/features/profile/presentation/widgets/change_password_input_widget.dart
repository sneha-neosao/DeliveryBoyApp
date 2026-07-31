import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/extensions/string_validator_extension.dart';
import 'package:delivery_boy_app/src/features/profile/presentation/widgets/change_password_textfield.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/injector/injector.dart';

class ChangePasswordInputWidget extends StatefulWidget {

  const ChangePasswordInputWidget({
    super.key,
  });

  @override
  State<ChangePasswordInputWidget> createState() => _ChangePasswordInputWidgetState();
}

class _ChangePasswordInputWidgetState extends State<ChangePasswordInputWidget> {

  @override
  Widget build(BuildContext context) {
    final formBloc = context.read<PasswordUpdateFormBloc>();

    return Column(
      children: [
        ChangePasswordTextField<PasswordUpdateFormBloc>(
          label: "old_password".tr(),
          prefixIcon: Icons.vpn_key_rounded,
          hintText: 'enter_old_password'.tr(),
          isSecure: true,
          onChanged: (val) {
            final trimmed = val.trim();
            formBloc.add(OldPasswordChangedEvent(trimmed));
          },
        ),
        16.hS,
        ChangePasswordTextField<PasswordUpdateFormBloc>(
          label: "new_password".tr(),
          prefixIcon: Icons.vpn_key_rounded,
          hintText: 'enter_new_password'.tr(),
          isSecure: true,
          onChanged: (val) {
            final trimmed = val.trim();
            formBloc.add(NewPasswordChangedEvent(trimmed));
          },
        ),
        16.hS,
        ChangePasswordTextField<PasswordUpdateFormBloc>(
          label: "confirm_password".tr(),
          prefixIcon: Icons.vpn_key_rounded,
          hintText: 'enter_confirm_password'.tr(),
          isSecure: true,
          onChanged: (val) {
            final trimmed = val.trim();
            formBloc.add(ConfirmPasswordChangedEvent(trimmed));
          },
        ),
      ],
    );
  }
}
