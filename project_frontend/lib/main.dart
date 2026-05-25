import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart' as di;
import 'features/client_booking/presentation/providers/service_selection_provider.dart';
import 'features/client_booking/presentation/providers/booking_provider.dart';
import 'features/admin_panel/presentation/providers/admin_provider.dart';
import 'features/admin_panel/presentation/providers/admin_service_provider.dart';
import 'features/admin_panel/presentation/providers/admin_brand_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null);

  await di.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => di.sl<ServiceSelectionProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminServiceProvider>()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AdminBrandProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zanin Detailer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      routerConfig: AppRouter.router,
    );
  }
}
