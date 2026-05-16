import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/client_booking/presentation/providers/service_selection_provider.dart';
import 'features/client_booking/presentation/providers/booking_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceSelectionProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: const ZaninDetailerApp(),
    ),
  );
}

class ZaninDetailerApp extends StatelessWidget {
  const ZaninDetailerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zanin Detailer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
