
import 'package:delivery_boy_app/src/core/utils/regex_validator.dart';

/// Extension on [String] that provides quick validation checks using predefined regex patterns.
extension StringValidatorExtension on String {
  bool get isEmailValid => RegexValidator.email.hasMatch(this);
  bool get isMobileNumberValid => RegexValidator.mobile.hasMatch(this);
  bool get isOtpValid => RegexValidator.otp.hasMatch(this);
  bool get isCommunityCodeValid => RegexValidator.communityCode.hasMatch(this);
}
