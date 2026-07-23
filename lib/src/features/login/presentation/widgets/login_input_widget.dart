import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/features/login/presentation/widgets/login_textfield.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/injector/injector.dart';

class LoginInputWidget extends StatelessWidget {
  const LoginInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final formBloc = context.read<AuthLoginFormBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mobile / Email Input
        LoginTextField<AuthLoginFormBloc>(
          label: 'email'.tr(),
          hintText: 'enter_your_email'.tr(),
          prefixIcon: Icons.phone_iphone_rounded,
          onChanged: (val) {
            final trimmed = val.trim();
            formBloc.add(LoginFormEmailChangedEvent(trimmed));
          },
          keyboardType: TextInputType.emailAddress,
        ),
        12.hS,

        // Password Input
        LoginTextField<AuthLoginFormBloc>(
          label: 'login_password_label'.tr(),
          hintText: 'login_password_hint'.tr(),
          prefixIcon: Icons.lock_outline_rounded,
          onChanged: (val) {
            final trimmed = val.trim();
            formBloc.add(LoginFormPasswordChangedEvent(trimmed));
          },
          isSecure: true,
        ),
      ],
    );
  }
}
