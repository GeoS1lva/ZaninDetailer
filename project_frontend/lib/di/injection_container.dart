import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_client.dart';
import '../features/auth/domain/repositories/i_auth_repository.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/admin_panel/domain/repositories/i_admin_repository.dart';
import '../features/admin_panel/data/repositories/admin_repository_impl.dart';
import '../features/admin_panel/presentation/providers/admin_service_provider.dart';
import '../features/admin_panel/presentation/providers/admin_provider.dart';
import '../features/admin_panel/presentation/providers/user_management_provider.dart';
import '../features/admin_panel/presentation/providers/admin_brand_provider.dart';
import '../features/client_booking/domain/repositories/i_booking_repository.dart';
import '../features/client_booking/data/repositories/booking_repository_impl.dart';
import '../features/client_booking/presentation/providers/service_selection_provider.dart';
import '../features/client_booking/presentation/providers/booking_provider.dart';
import '../features/admin_panel/data/repositories/user_management_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
  sl.registerLazySingleton<ApiClient>(
      () => ApiClient(storage: sl<FlutterSecureStorage>()));

  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(
        apiClient: sl<ApiClient>(),
        storage: sl<FlutterSecureStorage>(),
      ));
  sl.registerFactory(() => AuthProvider(repository: sl<IAuthRepository>()));

  sl.registerLazySingleton<IAdminRepository>(
      () => AdminRepositoryImpl(apiClient: sl()));
  sl.registerFactory(
      () => AdminServiceProvider(repository: sl<IAdminRepository>()));
  sl.registerFactory(() => AdminProvider(repository: sl<IAdminRepository>()));
  sl.registerFactory(() => UserManagementProvider(repository: sl()));
  sl.registerFactory(() => AdminBrandProvider(repository: sl()));

  sl.registerLazySingleton<UserManagementRepository>(
      () => UserManagementRepository(apiClient: sl<ApiClient>()));

  sl.registerLazySingleton<IBookingRepository>(
      () => BookingRepositoryImpl(apiClient: sl()));
  sl.registerFactory(
      () => ServiceSelectionProvider(repository: sl<IBookingRepository>()));
  sl.registerFactory(
      () => BookingProvider(repository: sl<IBookingRepository>()));
}
