import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/features/profile/presentation/widgets/edit_profile_textfield.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EditProfileInputWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController locationController;

  const EditProfileInputWidget({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.locationController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EditProfileTextField(
          label: "name".tr(),
          controller: nameController,
          prefixIcon: Icons.person_outline_rounded,
          hintText: 'Name',
        ),
        16.hS,
        EditProfileTextField(
          label: "mobile_number".tr(),
          controller: phoneController,
          prefixIcon: Icons.phone_android_rounded,
          hintText: 'Mobile Number',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}
