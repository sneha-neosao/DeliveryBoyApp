import 'package:delivery_boy_app/src/features/profile/presentation/widgets/edit_profile_textfield.dart';
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
          controller: nameController,
          prefixIcon: Icons.person_outline_rounded,
          hintText: 'Name',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        EditProfileTextField(
          controller: phoneController,
          prefixIcon: Icons.phone_android_rounded,
          hintText: 'Phone Number',
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        EditProfileTextField(
          controller: emailController,
          prefixIcon: Icons.email_outlined,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        EditProfileTextField(
          controller: locationController,
          prefixIcon: Icons.location_on_outlined,
          hintText: 'Location',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your location';
            }
            return null;
          },
        ),
      ],
    );
  }
}
