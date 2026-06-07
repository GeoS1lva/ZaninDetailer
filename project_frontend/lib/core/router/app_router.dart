import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../di/injection_container.dart' as di;
import '../../features/client_booking/data/models/service_model.dart';
import '../../features/admin_panel/data/models/admin_service_model.dart';
import '../../features/admin_panel/data/models/admin_brand_model.dart';
import '../../features/client_booking/presentation/pages/welcome_page.dart';
import '../../features/client_booking/presentation/pages/service_selection_page.dart';
import '../../features/client_booking/presentation/pages/booking_page.dart';
import '../../features/admin_panel/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin_panel/presentation/pages/user_management_page.dart';
import '../../features/admin_panel/presentation/pages/admin_services_list_page.dart';
import '../../features/admin_panel/presentation/pages/admin_new_service_page.dart';
import '../../features/admin_panel/presentation/pages/admin_edit_service_page.dart';
import '../../features/admin_panel/presentation/pages/admin_brands_list_page.dart';
import '../../features/admin_panel/presentation/pages/admin_new_brand_page.dart';
import '../../features/admin_panel/presentation/pages/admin_edit_brand_page.dart';
import '../../features/auth/presentation/pages/password_update_page.dart';
import '../../features/admin_panel/presentation/providers/admin_provider.dart';
import '../../features/admin_panel/presentation/providers/admin_service_provider.dart';
import '../../features/admin_panel/presentation/providers/user_management_provider.dart';
import '../../features/admin_panel/presentation/providers/admin_brand_provider.dart';

class AppRouter {
  static const String home = '/';
  static const String services = '/services';
  static const String booking = '/booking';
  static const String passwordUpdate = '/password-update';

  static const String admin = '/admin';
  static const String adminUsers = '/admin-usuarios';

  static const String adminServicosList = '/admin/services';
  static const String adminNovoServico = '/admin/new-service';
  static const String adminEditarServico = '/admin/services/edit';

  static const String adminMarcasList = '/admin/brands';
  static const String adminNovaMarca = '/admin/new-brand';
  static const String adminEditarMarca = '/admin/brands/edit';

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
        redirect: (context, state) {
          if (state.extra == null) return services;
          return null;
        },
        builder: (context, state) {
          final service = state.extra as ServiceModel;
          return BookingPage(service: service);
        },
      ),
      GoRoute(
        path: passwordUpdate,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return PasswordUpdatePage(resetToken: token);
        },
      ),
      GoRoute(
        path: admin,
        redirect: (context, state) async {
          final storage = di.sl<FlutterSecureStorage>();
          final token = await storage.read(key: 'access_token');

          if (token == null || token.isEmpty) {
            return services;
          }
          return null;
        },
        builder: (context, state) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => di.sl<AdminProvider>()),
            ChangeNotifierProvider(
                create: (_) => di.sl<AdminServiceProvider>()),
            ChangeNotifierProvider(create: (_) => di.sl<AdminBrandProvider>()),
          ],
          child: const AdminDashboardPage(),
        ),
        routes: [
          GoRoute(
            path: adminUsers,
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) => di.sl<UserManagementProvider>(),
              child: const UserManagementPage(),
            ),
          ),
          GoRoute(
            path: 'services',
            builder: (context, state) => const AdminServicesListPage(),
          ),
          GoRoute(
            path: 'services/edit',
            builder: (context, state) {
              final services = state.extra as AdminServiceModel;
              return AdminEditServicePage(servico: services);
            },
          ),
          GoRoute(
            path: 'new-service',
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
            path: 'brands',
            builder: (context, state) => const AdminBrandsListPage(),
          ),
          GoRoute(
            path: 'marcas/editar',
            builder: (context, state) {
              final marca = state.extra as AdminBrandModel;
              return AdminEditBrandPage(marca: marca);
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
