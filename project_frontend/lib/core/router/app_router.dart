import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/client_booking/data/models/service_model.dart';
import '../../features/client_booking/presentation/pages/welcome_page.dart';
import '../../features/client_booking/presentation/pages/service_selection_page.dart';
import '../../features/client_booking/presentation/pages/booking_page.dart';
import '../../features/admin_panel/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin_panel/presentation/pages/admin_new_service_page.dart';
import '../../features/admin_panel/presentation/pages/admin_new_brand_page.dart';

class AppRouter {
  static const String home = '/';
  static const String services = '/services';
  static const String booking = '/booking';
  static const String admin = '/admin';
  static const String adminNovoServico = '/admin/novo-servico';
  static const String adminNovaMarca = '/admin/nova-marca';

  static final router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: services,
        builder: (context, state) => const ServiceSelectionPage(),
      ),
      GoRoute(
        path: booking,
        builder: (context, state) {
          final service = state.extra as ServiceModel;
          return BookingPage(service: service);
        },
      ),
      GoRoute(
        path: admin,
        builder: (context, state) => const AdminDashboardPage(),
        routes: [
          GoRoute(
            path: 'novo-servico',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AdminNewServicePage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOutQuart;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                      position: animation.drive(tween), child: child);
                },
              );
            },
          ),
          GoRoute(
            path: 'nova-marca',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AdminNewBrandPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOutQuart;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                      position: animation.drive(tween), child: child);
                },
              );
            },
          ),
        ],
      ),
    ],
  );
}
