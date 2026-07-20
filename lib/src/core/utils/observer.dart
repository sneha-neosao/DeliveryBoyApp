import 'package:flutter_bloc/flutter_bloc.dart';

import 'logger.dart';

/// Custom BLoC observer to log BLoC events, state changes, and errors.
/// Useful for debugging and monitoring the behavior of all BLoCs in the app.
class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    logger.e(error);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    logger.d(change.currentState);
    logger.d(change.nextState);
    super.onChange(bloc, change);
  }
}
