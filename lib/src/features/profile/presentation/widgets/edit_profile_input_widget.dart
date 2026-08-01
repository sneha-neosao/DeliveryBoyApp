import 'package:delivery_boy_app/src/configs/injector/injector.dart';
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
    required this.phone,
  });

  @override
  State<EditProfileInputWidget> createState() =>
      _EditProfileInputWidgetState();
}

class _EditProfileInputWidgetState extends State<EditProfileInputWidget> {
  late final ProfileUpdateFormBloc _formBloc;

  @override
  void initState() {
    super.initState();

    _formBloc = context.read<ProfileUpdateFormBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formBloc.add(NameChangedEvent(widget.name));
      _formBloc.add(MobileNumberChangedEvent(widget.phone));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EditProfileTextField<ProfileUpdateFormBloc>(
          label: "name".tr(),
          initialValue: widget.name,
          prefixIcon: Icons.person_outline_rounded,
          hintText: 'enter_name'.tr(),
          onChanged: (val) {
            _formBloc.add(NameChangedEvent(val.trim()));
          },
        ),
        16.hS,
        EditProfileTextField<ProfileUpdateFormBloc>(
          label: "mobile_number".tr(),
          initialValue: widget.phone,
          prefixIcon: Icons.phone_android_rounded,
          hintText: 'enter_mobile_number'.tr(),
          keyboardType: TextInputType.phone,
          onChanged: (val) {
            _formBloc.add(MobileNumberChangedEvent(val.trim()));
          },
        ),
      ],
    );
  }
}