import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/features/profile/presentation/widgets/edit_profile_textfield.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class EditProfileInputWidget extends StatefulWidget {
  final String name;
  final String phone;

  const EditProfileInputWidget({
    super.key,
    required this.name,
    required this.phone
});

  @override
  State<EditProfileInputWidget> createState() => _EditProfileInputWidgetState();
}

class _EditProfileInputWidgetState extends State<EditProfileInputWidget> {
  @override
  Widget build(BuildContext context) {
    // final formBloc = context.read<PasswordUpdateFormBloc>();

    return Column(
      children: [
        EditProfileTextField(
          label: "name".tr(),
          initialValue: widget.name,
          prefixIcon: Icons.person_outline_rounded,
          hintText: 'Name',
        ),
        16.hS,
        EditProfileTextField(
          label: "mobile_number".tr(),
          initialValue: widget.phone,
          prefixIcon: Icons.phone_android_rounded,
          hintText: 'Mobile Number',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}
