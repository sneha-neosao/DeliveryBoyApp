part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final bool? isDarkMode; // null = follow system
  const ThemeState({this.isDarkMode});

  @override
  List<Object?> get props => [isDarkMode];

  factory ThemeState.fromMap(Map<String, dynamic> map) {
    return ThemeState(isDarkMode: map["isDarkMode"] as bool?);
  }

  Map<String, dynamic> toMap() {
    return {"isDarkMode": isDarkMode};
  }
}
