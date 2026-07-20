part of 'translate_bloc.dart';

class TranslateState extends Equatable {
  final String languageCode;
  final String countryCode;

  const TranslateState(this.languageCode, this.countryCode);

  bool get isMarathi => languageCode == 'mr';
  bool get isHindi => languageCode == 'hi';
  bool get isGujarati => languageCode == 'gu';
  bool get isKannada => languageCode == 'kn';

  @override
  List<Object> get props => [languageCode, countryCode];

  factory TranslateState.fromMap(Map<String, dynamic> map) {
    return TranslateState(
      map["language_code"] ?? "en",
      map["country_code"] ?? "US",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "language_code": languageCode,
      "country_code": countryCode,
    };
  }
}
