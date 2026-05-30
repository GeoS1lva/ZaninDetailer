import 'package:get_it/get_it.dart';
import '../core/network/api_client.dart';
import '../features/admin_panel/domain/repositories/i_admin_repository.dart';
import '../features/admin_panel/data/repositories/admin_repository_impl.dart';
import '../features/admin_panel/presentation/providers/admin_service_provider.dart';
import '../features/admin_panel/presentation/providers/admin_provider.dart';
import '../features/client_booking/domain/repositories/i_booking_repository.dart';
import '../features/client_booking/data/repositories/booking_repository_impl.dart';
import '../features/client_booking/presentation/providers/service_selection_provider.dart';
import '../features/client_booking/presentation/providers/booking_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  sl.registerLazySingleton<IAdminRepository>(() => AdminRepositoryImpl());
  sl.registerFactory(
      () => AdminServiceProvider(repository: sl<IAdminRepository>()));

  sl.registerFactory(() => AdminProvider(repository: sl<IAdminRepository>()));

  sl.registerLazySingleton<IBookingRepository>(() => BookingRepositoryImpl());
  sl.registerFactory(
      () => ServiceSelectionProvider(repository: sl<IBookingRepository>()));
  sl.registerFactory(
      () => BookingProvider(repository: sl<IBookingRepository>()));
}
