import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'configs/injector/injector.dart';
import 'configs/injector/injector_conf.dart';
import 'core/blocs/theme/theme_bloc.dart';
import 'core/blocs/translate/translate_bloc.dart';
import 'core/constants/list_translation_locale.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/global_keys.dart';
import 'routes/app_route_conf.dart';
import 'routes/app_route_path.dart';

/// Root widget for the app. Handles initialization and routing.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// State for MyApp. Sets up router and deep link listeners.
class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = getIt<AppRouteConf>().router;
  }

  /// Builds the main app widget tree with theming, localization, and routing.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GestureDetector(
        onTap: () => primaryFocus?.unfocus(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<ThemeBloc>()),
            BlocProvider(create: (_) => getIt<TranslateBloc>()),
          ],
          child: BlocListener<TranslateBloc, TranslateState>(
            listener: (ctx, translateState) {
              final newLocale = translateState.isMarathi
                  ? marathiLocale
                  : englishLocale;
              ctx.setLocale(newLocale);
            },
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (_, state) {
                return MaterialApp.router(
                  scaffoldMessengerKey: scaffoldMessengerKey,
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  theme: AppTheme.data(false),
                  darkTheme: AppTheme.data(true),
                  themeMode: ThemeMode.light,
                  routerConfig: _router,
                  builder: (context, child) {
                    final mediaQuery = MediaQuery.of(context);

                    return MediaQuery(
                      data: mediaQuery.copyWith(
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      child: child!,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
