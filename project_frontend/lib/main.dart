import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart' as di;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await di.init();

  runApp(const ZaninDetailerApp());
}

class ZaninDetailerApp extends StatelessWidget {
  const ZaninDetailerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zanin Detailer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      routerConfig: AppRouter.router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
    );
  }
}
