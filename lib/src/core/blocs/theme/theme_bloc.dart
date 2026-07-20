import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_event.dart';
part 'theme_state.dart';

/// Handles state management for **Themes** and its related entities.

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<LightThemeEvent>((_, emit) => emit(const ThemeState(isDarkMode: false)));
    on<DarkThemeEvent>((_, emit) => emit(const ThemeState(isDarkMode: true)));
    on<SystemThemeEvent>((_, emit) => emit(const ThemeState(isDarkMode: null)));
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) => ThemeState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(ThemeState state) => state.toMap();
}
