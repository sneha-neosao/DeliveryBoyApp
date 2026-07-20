/// Utility class containing commonly used regular expressions for validation.
/// Designed as a static-only class with a private constructor to prevent instantiation.
class RegexValidator {
  RegexValidator._();

  static final email = RegExp(r"^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$");
  static final mobile = RegExp(r"^[6-9]\d{9}$");
  static final otp = RegExp(r'^.{4}$');
  static final RegExp communityCode = RegExp(r'^[A-Z0-9]+$');
}
