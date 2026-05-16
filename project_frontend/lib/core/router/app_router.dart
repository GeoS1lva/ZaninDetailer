import 'package:go_router/go_router.dart';
import '../../features/client_booking/presentation/pages/welcome_page.dart';
import '../../features/client_booking/presentation/pages/service_selection_page.dart';
import '../../features/client_booking/presentation/pages/booking_page.dart';
import '../../features/client_booking/presentation/providers/service_selection_provider.dart';

class AppRouter {
  static const String welcome = '/';
  static const String services = '/services';
  static const String booking = '/booking';

  static final router = GoRouter(
    initialLocation: welcome,
    routes: [
      GoRoute(
        path: welcome,
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
    ],
  );
}
