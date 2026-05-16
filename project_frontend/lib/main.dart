import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/client_booking/presentation/pages/welcome_page.dart';

void main() {
  runApp(const ZaninDetailerApp());
}

class ZaninDetailerApp extends StatelessWidget {
  const ZaninDetailerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zanin Detailer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomePage(), 
    );
  }
}
