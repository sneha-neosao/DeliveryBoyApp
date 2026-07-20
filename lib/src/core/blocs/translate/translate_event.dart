part of 'translate_bloc.dart';

sealed class TranslateEvent extends Equatable {
  const TranslateEvent();

  @override
  List<Object> get props => [];
}

class TrMarathiEvent extends TranslateEvent {}

class TrEnglishEvent extends TranslateEvent {}

class TrHindiEvent extends TranslateEvent {}

class TrGujaratiEvent extends TranslateEvent {}

class TrKannadaEvent extends TranslateEvent {}
